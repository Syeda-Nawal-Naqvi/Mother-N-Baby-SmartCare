import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // v7.x: only GoogleSignIn.instance exists — no public constructor.
  // Call initialize() once at app startup (done in main.dart or here lazily).
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await _googleSignIn.initialize();
    _googleInitialized = true;
  }

  User? get currentUser => _auth.currentUser;

  String _mapError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'user-blocked':
        return 'Your account has been blocked. Contact admin.';
      case 'requires-recent-login':
        return 'For security, please re-enter your password to continue.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  Future<UserCredential> _doEmailLogin(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // ── Login ──────────────────────────────────────────────────────────────
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signOut();
    } catch (_) {}

    Future<String?> attempt() async {
      try {
        final cred = await _doEmailLogin(email, password);
        final doc =
            await _firestore.collection('users').doc(cred.user!.uid).get();
        if (doc.exists && (doc.data()?['blocked'] == true)) {
          await _auth.signOut();
          return _mapError('user-blocked');
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isFirstTime', false);
        await prefs.setBool('isLoggedIn', true);
        return null;
      } on FirebaseAuthException catch (e) {
        return _mapError(e.code);
      } catch (_) {
        return 'Login failed. Please try again.';
      }
    }

    final result = await attempt();
    if (result != null && result.contains('Too many attempts')) {
      await Future.delayed(const Duration(seconds: 4));
      return await attempt();
    }
    return result;
  }

  // ── Google Sign-In ─────────────────────────────────────────────────────
  // v7.x API:
  //   - GoogleSignIn.instance  (singleton, no public constructor)
  //   - initialize() must be called before authenticate()
  //   - authenticate() throws GoogleSignInException on cancel/failure
  //   - account.authentication  → GoogleSignInAuthentication { idToken }
  //   - accessToken comes from account.authorizationClient.authorizeScopes()
  Future<Map<String, dynamic>> signInWithGoogle({String? defaultRole}) async {
    try {
      await _ensureGoogleInitialized();
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (_) {}

    try {
      // authenticate() throws GoogleSignInException on cancel — never returns null
      final googleUser = await _googleSignIn.authenticate();

      // idToken from authentication getter (sync, not async)
      final String? idToken = googleUser.authentication.idToken;

      // accessToken requires authorization
      String? accessToken;
      try {
        final authz = await googleUser.authorizationClient
            .authorizeScopes(['email', 'profile']);
        accessToken = authz.accessToken;
      } catch (_) {
        // accessToken is optional for Firebase — idToken alone may work
      }

      if (idToken == null) {
        return {'error': 'Google authentication failed. Please try again.'};
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user!;

      final docRef = _firestore.collection('users').doc(user.uid);
      final doc = await docRef.get();
      String role;

      if (!doc.exists) {
        role = defaultRole ?? 'mother';
        await docRef.set({
          'name': user.displayName ?? googleUser.displayName ?? '',
          'email': user.email ?? googleUser.email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'blocked': false,
        });
      } else {
        if (doc.data()?['blocked'] == true) {
          await _auth.signOut();
          await _googleSignIn.signOut();
          return {'error': _mapError('user-blocked')};
        }
        role = doc.data()?['role'] ?? 'mother';
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstTime', false);
      await prefs.setBool('isLoggedIn', true);
      return {'error': null, 'role': role};
    } on GoogleSignInException catch (e) {
      // Covers cancel, interrupted, config errors etc.
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return {'error': 'Google sign-in was cancelled.'};
      }
      try {
        await _googleSignIn.signOut();
        await _auth.signOut();
      } catch (_) {}
      return {'error': 'Google sign-in failed. Please try again.'};
    } on FirebaseAuthException catch (e) {
      try {
        await _googleSignIn.signOut();
        await _auth.signOut();
      } catch (_) {}
      return {'error': _mapError(e.code)};
    } catch (_) {
      try {
        await _googleSignIn.signOut();
        await _auth.signOut();
      } catch (_) {}
      return {'error': 'Google sign-in failed. Please try again.'};
    }
  }

  // ── Register ───────────────────────────────────────────────────────────
  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'blocked': false,
      });
      await cred.user!.sendEmailVerification();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstTime', false);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    } catch (_) {
      return 'Registration failed. Please try again.';
    }
  }

  // ── Email verification ─────────────────────────────────────────────────
  Future<bool> checkEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<String?> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'No user logged in.';
      await user.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    } catch (_) {
      return 'Failed to resend email. Please try again.';
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (_) {}
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
  }

  // ── Password reset ─────────────────────────────────────────────────────
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    } catch (_) {
      return 'Failed to send reset email. Please try again.';
    }
  }

  // ── Change password ────────────────────────────────────────────────────
  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return 'No user logged in.';
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    } catch (_) {
      return 'Failed to change password. Please try again.';
    }
  }

  // ── Change email ───────────────────────────────────────────────────────
  Future<String?> requestEmailChange(
      String newEmail, String currentPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return 'No user logged in.';
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.verifyBeforeUpdateEmail(newEmail.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    } catch (_) {
      return 'Failed to update email. Please try again.';
    }
  }

  // ── Sync email after verification ──────────────────────────────────────
  Future<void> syncEmailAfterVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return;
      await user.reload();
      final freshUser = _auth.currentUser;
      if (freshUser == null || freshUser.email == null) return;
      final docRef = _firestore.collection('users').doc(freshUser.uid);
      final doc = await docRef.get();
      if (doc.exists && doc.data()?['email'] != freshUser.email) {
        await docRef.update({'email': freshUser.email});
      }
    } catch (_) {}
  }

  // ── Get user role ──────────────────────────────────────────────────────
  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists ? (doc.data()?['role'] ?? 'mother') : 'mother';
    } catch (_) {
      return 'mother';
    }
  }

  // ── Delete account ─────────────────────────────────────────────────────
  Future<String?> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'No user logged in.';
      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    } catch (_) {
      return 'Failed to delete account. Please try again.';
    }
  }
}
