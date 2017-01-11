$(function () {
  $('#container').highcharts({
      title: {
        text: null
      },
      yAxis: {
        title: {
          text: null
        }
      },
      credits: {
        enabled: false
      },
      exporting: {
        enabled: false
      },
      plotOptions: {
        series: {
          turboThreshold: 0,
          borderWidth: 0,
          pointWidth: 4
        },
        treemap: {
          layoutAlgorithm: "squarified"
        },
        bubble: {
          minSize: 5,
          maxSize: 25
        }
      },
      annotationsOptions: {
        enabledButtons: false
      },
      tooltip: {
        delayForDisplay: 10,
        shared: true,
        useHTML: true,
        headerFormat: "<small>\n  {point.x: %b %d}\n  <br/>\n</small>"
      },
      xAxis: {
        type: "datetime",
        showLastLabel: false,
        dateTimeLabelFormats: {
          month: "%B"
        }
      }
    }
  );
});
