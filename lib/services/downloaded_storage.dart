import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:receipe_book/model/recipe.dart';
import 'package:receipe_book/services/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadedStorage extends ChangeNotifier implements Storage {
  List<Recipe> _recipes = [];

  @override
  Future<List<Recipe>> fetch() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList('downloaded') ?? [];
    _recipes = items.map((item) => Recipe.fromJson(jsonDecode(item))).toList();

    return _recipes;
  }

  @override
  bool add(Recipe recipe) {
    if (_recipes
        .any((oldRecipe) => jsonEncode(oldRecipe) == jsonEncode(recipe)))
      return false;

    _recipes.add(recipe);
    _update();
    notifyListeners();
    return true;
  }

  @override
  void edit(Recipe oldRecipe, Recipe newRecipe) {
    // to compare the object, change it to string because of reference diff
    final index = _recipes
        .indexWhere((recipe) => jsonEncode(recipe) == jsonEncode(oldRecipe));
    _recipes[index] = newRecipe;

    _update();
    notifyListeners();
  }

  @override
  void remove(Recipe recipe) {
    final index = _recipes.indexOf(recipe);
    _recipes.removeAt(index);

    _update();
    notifyListeners();
  }

  Future<void> _update() async {
    final items =
        _recipes.map((recipe) => jsonEncode(recipe.toJson())).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('downloaded', items);
  }
}