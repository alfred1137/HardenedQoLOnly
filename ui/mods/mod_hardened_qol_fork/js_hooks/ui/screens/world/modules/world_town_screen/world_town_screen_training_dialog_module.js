// Vanilla Fix: We reduce the scroll speed of the origin list to 1.0 (down from 8.85)
Hardened.Hooks.WorldTownScreenTrainingDialogModule_createDIV =
  WorldTownScreenTrainingDialogModule.prototype.createDIV;
WorldTownScreenTrainingDialogModule.prototype.createDIV = function (
  _parentDiv,
) {
  // We switcheroo the jquery createList function as that is the simplest way to switch out the high vanilla delta with a smaller one
  var oldCreateList = $.fn.createList;
  $.fn.createList = function (_scrollDelta, _classes, _withoutFrame) {
    return oldCreateList.call(this, 1.0, _classes, _withoutFrame);
  };

  Hardened.Hooks.WorldTownScreenTrainingDialogModule_createDIV.call(
    this,
    _parentDiv,
  );

  $.fn.createList = oldCreateList;
};
