Highcharts.SVGRenderer.prototype.symbols['double-circle'] = function (x, y, w, h) {
    var outerCircleX = x + w / 2 - w;
    var outerCircleY = y + h / 2;
    var innerCircleX = outerCircleX + w / 2;
    var innerCircleY = outerCircleY;

    return [
        'M', outerCircleX + w / 2, outerCircleY,
        'a', w / 2, h / 2, 0, 1, 0, w, 0,
        'a', w / 2, h / 2, 0, 1, 0, -w, 0,
        'M', innerCircleX + w / 4, innerCircleY,
        'a', w / 4, h / 4, 0, 1, 0, w / 2, 0,
        'a', w / 4, h / 4, 0, 1, 0, -w / 2, 0
    ];
};

if (Highcharts.VMLRenderer) {
    Highcharts.VMLRenderer.prototype.symbols['double-circle'] = Highcharts.SVGRenderer.prototype.symbols['double-circle'];
}
