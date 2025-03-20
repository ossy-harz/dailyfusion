import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// A service for storing and retrieving data locally.
/// This implementation uses SharedPreferences for simplicity.
/// In a real app, this would be replaced with SQLite, Hive, or another database.
class StorageService {
  Future<List<Map<String, dynamic>>> getCollection(String collection) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(collection);
      
      if (jsonString == null) {
        return [];
      }
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error getting collection $collection: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>?> getDocument(String collection, String id) async {
    try {
      final documents = await getCollection(collection);
      return documents.firstWhere((doc) => doc['id'] == id);
    } catch (e) {
      debugPrint('Error getting document $id from $collection: $e');
      return null;
    }
  }
  
  Future<void> addDocument(String collection, Map<String, dynamic> document) async {
    try {
      final documents = await getCollection(collection);
      documents.add(document);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(collection, json.encode(documents));
    } catch (e) {
      debugPrint('Error adding document to $collection: $e');
    }
  }
  
  Future<void> updateDocument(String collection, String id, Map<String, dynamic> document) async {
    try {
      final documents = await getCollection(collection);
      final index = documents.indexWhere((doc) => doc['id'] == id);
      
      if (index != -1) {
        documents[index] = document;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(collection, json.encode(documents));
      }
    } catch (e) {
      debugPrint('Error updating document $id in $collection: $e');
    }
  }
  
  Future<void> deleteDocument(String collection, String id) async {
    try {
      final documents = await getCollection(collection);
      documents.removeWhere((doc) => doc['id'] == id);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(collection, json.encode(documents));
    } catch (e) {
      debugPrint('Error deleting document $id from $collection: $e');
    }
  }
  
  Future<void> clearCollection(String collection) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(collection);
    } catch (e) {
      debugPrint('Error clearing collection $collection: $e');
    }
  }
}

