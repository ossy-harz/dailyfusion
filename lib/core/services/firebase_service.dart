import 'package:dailyfusion/core/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();
  
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  
  // Authentication methods
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }
  
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
  
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Error resetting password: $e');
      rethrow;
    }
  }
  
  // Firestore methods
  Future<void> syncLocalDataToFirestore() async {
    if (!isLoggedIn) return;
    
    try {
      final userId = currentUser!.uid;
      
      // Sync tasks
      final tasks = await _storageService.getCollection('tasks');
      for (final task in tasks) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('tasks')
            .doc(task['id'])
            .set(task);
      }
      
      // Sync fitness data
      final workouts = await _storageService.getCollection('workouts');
      for (final workout in workouts) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('workouts')
            .doc(workout['id'])
            .set(workout);
      }
      
      // Sync budget data
      final transactions = await _storageService.getCollection('transactions');
      for (final transaction in transactions) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc(transaction['id'])
            .set(transaction);
      }
      
      final budgets = await _storageService.getCollection('budgets');
      for (final budget in budgets) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('budgets')
            .doc(budget['id'])
            .set(budget);
      }
      
      // Sync book data
      final recipes = await _storageService.getCollection('recipes');
      for (final recipe in recipes) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('recipes')
            .doc(recipe['id'])
            .set(recipe);
      }
      
      final guides = await _storageService.getCollection('guides');
      for (final guide in guides) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('guides')
            .doc(guide['id'])
            .set(guide);
      }
      
      // Sync journal entries
      final entries = await _storageService.getCollection('journal_entries');
      for (final entry in entries) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('journal_entries')
            .doc(entry['id'])
            .set(entry);
      }
      
      // Sync user profile
      final userProfile = await _storageService.getDocument('users', userId);
      if (userProfile != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .set(userProfile);
      }
    } catch (e) {
      debugPrint('Error syncing data to Firestore: $e');
      rethrow;
    }
  }
  
  Future<void> syncFirestoreToLocalData() async {
    if (!isLoggedIn) return;
    
    try {
      final userId = currentUser!.uid;
      
      // Sync tasks
      final tasksSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .get();
      
      for (final doc in tasksSnapshot.docs) {
        await _storageService.updateDocument('tasks', doc.id, doc.data());
      }
      
      // Sync fitness data
      final workoutsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('workouts')
          .get();
      
      for (final doc in workoutsSnapshot.docs) {
        await _storageService.updateDocument('workouts', doc.id, doc.data());
      }
      
      // Sync budget data
      final transactionsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .get();
      
      for (final doc in transactionsSnapshot.docs) {
        await _storageService.updateDocument('transactions', doc.id, doc.data());
      }
      
      final budgetsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .get();
      
      for (final doc in budgetsSnapshot.docs) {
        await _storageService.updateDocument('budgets', doc.id, doc.data());
      }
      
      // Sync book data
      final recipesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('recipes')
          .get();
      
      for (final doc in recipesSnapshot.docs) {
        await _storageService.updateDocument('recipes', doc.id, doc.data());
      }
      
      final guidesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('guides')
          .get();
      
      for (final doc in guidesSnapshot.docs) {
        await _storageService.updateDocument('guides', doc.id, doc.data());
      }
      
      // Sync journal entries
      final entriesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('journal_entries')
          .get();
      
      for (final doc in entriesSnapshot.docs) {
        await _storageService.updateDocument('journal_entries', doc.id, doc.data());
      }
      
      // Sync user profile
      final userSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (userSnapshot.exists) {
        await _storageService.updateDocument('users', userId, userSnapshot.data()!);
      }
    } catch (e) {
      debugPrint('Error syncing data from Firestore: $e');
      rethrow;
    }
  }
  
  // Listen for real-time updates
  Stream<QuerySnapshot> getCollectionStream(String collection) {
    if (!isLoggedIn) {
      throw Exception('User not logged in');
    }
    
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection(collection)
        .snapshots();
  }
  
  Stream<DocumentSnapshot> getDocumentStream(String collection, String documentId) {
    if (!isLoggedIn) {
      throw Exception('User not logged in');
    }
    
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection(collection)
        .doc(documentId)
        .snapshots();
  }
}

