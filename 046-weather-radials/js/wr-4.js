$(function () {
  $('#container').highcharts({
      title: {
        text: {}
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
          stacking: "normal",
          showInLegend: false
        }
      },
      chart: {
        type: "column",
        polar: true
      },
      xAxis: {
        gridLineWidth: 0.5,
        type: "datetime",
        tickInterval: 2592000000,
        labels: {
          format: "{value: %b}"
        }
      },
      yAxis: {
        max: 30,
        min: -10,
        labels: {
          format: "{value}°C"
        },
        showFirstLabel: false
      },
      series: [
        {
          data: [
            {
              x: 1388534400000,
              y: 8,
              name: "2014-01-01",
              color: "#010106",
              mean: 9,
              max: 13,
              min: 5
            },
            {
              x: 1388620800000,
              y: 11,
              name: "2014-01-02",
              color: "#110C2F",
              mean: 12,
              max: 17,
              min: 6
            },
            {
              x: 1388707200000,
              y: 11,
              name: "2014-01-03",
              color: "#110C2F",
              mean: 12,
              max: 18,
              min: 7
            },
            {
              x: 1388793600000,
              y: 13,
              name: "2014-01-04",
              color: "#301164",
              mean: 13,
              max: 19,
              min: 6
            },
            {
              x: 1388880000000,
              y: 12,
              name: "2014-01-05",
              color: "#301164",
              mean: 13,
              max: 19,
              min: 7
            },
            {
              x: 1388966400000,
              y: 9,
              name: "2014-01-06",
              color: "#060519",
              mean: 11,
              max: 16,
              min: 7
            },
            {
              x: 1389052800000,
              y: 8,
              name: "2014-01-07",
              color: "#110C2F",
              mean: 12,
              max: 16,
              min: 8
            },
            {
              x: 1389139200000,
              y: 4,
              name: "2014-01-08",
              color: "#301164",
              mean: 13,
              max: 15,
              min: 11
            },
            {
              x: 1389225600000,
              y: 5,
              name: "2014-01-09",
              color: "#301164",
              mean: 13,
              max: 16,
              min: 11
            },
            {
              x: 1389312000000,
              y: 7,
              name: "2014-01-10",
              color: "#110C2F",
              mean: 12,
              max: 16,
              min: 9
            },
            {
              x: 1389398400000,
              y: 6,
              name: "2014-01-11",
              color: "#060519",
              mean: 11,
              max: 14,
              min: 8
            },
            {
              x: 1389484800000,
              y: 8,
              name: "2014-01-12",
              color: "#110C2F",
              mean: 12,
              max: 16,
              min: 8
            },
            {
              x: 1389571200000,
              y: 13,
              name: "2014-01-13",
              color: "#301164",
              mean: 13,
              max: 19,
              min: 6
            },
            {
              x: 1389657600000,
              y: 15,
              name: "2014-01-14",
              color: "#5E187F",
              mean: 14,
              max: 22,
              min: 7
            },
            {
              x: 1389744000000,
              y: 14,
              name: "2014-01-15",
              color: "#AA337D",
              mean: 16,
              max: 23,
              min: 9
            },
            {
              x: 1389830400000,
              y: 15,
              name: "2014-01-16",
              color: "#AA337D",
              mean: 16,
              max: 23,
              min: 8
            },
            {
              x: 1389916800000,
              y: 12,
              name: "2014-01-17",
              color: "#301164",
              mean: 13,
              max: 19,
              min: 7
            },
            {
              x: 1390003200000,
              y: 13,
              name: "2014-01-18",
              color: "#301164",
              mean: 13,
              max: 19,
              min: 6
            },
            {
              x: 1390089600000,
              y: 13,
              name: "2014-01-19",
              color: "#301164",
              mean: 13,
              max: 19,
              min: 6
            },
            {
              x: 1390176000000,
              y: 13,
              name: "2014-01-20",
              color: "#301164",
              mean: 13,
              max: 19,
              min: 6
            },
            {
              x: 1390262400000,
              y: 14,
              name: "2014-01-21",
              color: "#301164",
              mean: 13,
              max: 20,
              min: 6
            },
            {
              x: 1390348800000,
              y: 11,
              name: "2014-01-22",
              color: "#301164",
              mean: 13,
              max: 18,
              min: 7
            },
            {
              x: 1390435200000,
              y: 14,
              name: "2014-01-23",
              color: "#5E187F",
              mean: 14,
              max: 21,
              min: 7
            },
            {
              x: 1390521600000,
              y: 10,
              name: "2014-01-24",
              color: "#301164",
              mean: 13,
              max: 18,
              min: 8
            },
            {
              x: 1390608000000,
              y: 9,
              name: "2014-01-25",
              color: "#5E187F",
              mean: 14,
              max: 18,
              min: 9
            },
            {
              x: 1390694400000,
              y: 10,
              name: "2014-01-26",
              color: "#5E187F",
              mean: 14,
              max: 19,
              min: 9
            },
            {
              x: 1390780800000,
              y: 6,
              name: "2014-01-27",
              color: "#110C2F",
              mean: 12,
              max: 15,
              min: 9
            },
            {
              x: 1390867200000,
              y: 6,
              name: "2014-01-28",
              color: "#711F81",
              mean: 15,
              max: 18,
              min: 12
            },
            {
              x: 1390953600000,
              y: 5,
              name: "2014-01-29",
              color: "#711F81",
              mean: 15,
              max: 17,
              min: 12
            },
            {
              x: 1391040000000,
              y: 3,
              name: "2014-01-30",
              color: "#301164",
              mean: 13,
              max: 14,
              min: 11
            },
            {
              x: 1391126400000,
              y: 8,
              name: "2014-01-31",
              color: "#110C2F",
              mean: 12,
              max: 16,
              min: 8
            },
            {
              x: 1391212800000,
              y: 9,
              name: "2014-02-01",
              color: "#060519",
              mean: 11,
              max: 15,
              min: 6
            },
            {
              x: 1391299200000,
              y: 6,
              name: "2014-02-02",
              color: "#110C2F",
              mean: 12,
              max: 14,
              min: 8
            },
            {
              x: 1391385600000,
              y: 5,
              name: "2014-02-03",
              color: "#060519",
              mean: 11,
              max: 13,
              min: 8
            },
            {
              x: 1391472000000,
              y: 6,
              name: "2014-02-04",
              color: "#02020C",
              mean: 10,
              max: 13,
              min: 7
            },
            {
              x: 1391558400000,
              y: 7,
              name: "2014-02-05",
              color: "#010106",
              mean: 9,
              max: 13,
              min: 6
            },
            {
              x: 1391644800000,
              y: 2,
              name: "2014-02-06",
              color: "#02020C",
              mean: 10,
              max: 11,
              min: 9
            },
            {
              x: 1391731200000,
              y: 2,
              name: "2014-02-07",
              color: "#110C2F",
              mean: 12,
              max: 13,
              min: 11
            },
            {
              x: 1391817600000,
              y: 3,
              name: "2014-02-08",
              color: "#301164",
              mean: 13,
              max: 15,
              min: 12
            },
            {
              x: 1391904000000,
              y: 2,
              name: "2014-02-09",
              color: "#5E187F",
              mean: 14,
              max: 15,
              min: 13
            },
            {
              x: 1391990400000,
              y: 3,
              name: "2014-02-10",
              color: "#110C2F",
              mean: 12,
              max: 14,
              min: 11
            },
            {
              x: 1392076800000,
              y: 4,
              name: "2014-02-11",
              color: "#110C2F",
              mean: 12,
              max: 13,
              min: 9
            },
            {
              x: 1392163200000,
              y: 5,
              name: "2014-02-12",
              color: "#060519",
              mean: 11,
              max: 13,
              min: 8
            },
            {
              x: 1392249600000,
              y: 9,
              name: "2014-02-13",
              color: "#711F81",
              mean: 15,
              max: 19,
              min: 10
            },
            {
              x: 1392336000000,
              y: 6,
              name: "2014-02-14",
              color: "#AA337D",
              mean: 16,
              max: 19,
              min: 13
            },
            {
              x: 1392422400000,
              y: 6,
              name: "2014-02-15",
              color: "#5E187F",
              mean: 14,
              max: 17,
              min: 11
            },
            {
              x: 1392508800000,
              y: 7,
              name: "2014-02-16",
              color: "#5E187F",
              mean: 14,
              max: 17,
              min: 10
            },
            {
              x: 1392595200000,
              y: 8,
              name: "2014-02-17",
              color: "#110C2F",
              mean: 12,
              max: 16,
              min: 8
            },
            {
              x: 1392681600000,
              y: 8,
              name: "2014-02-18",
              color: "#301164",
              mean: 13,
              max: 17,
              min: 9
            },
            {
              x: 1392768000000,
              y: 6,
              name: "2014-02-19",
              color: "#5E187F",
              mean: 14,
              max: 17,
              min: 11
            },
            {
              x: 1392854400000,
              y: 12,
              name: "2014-02-20",
              color: "#301164",
              mean: 13,
              max: 19,
              min: 7
            },
            {
              x: 1392940800000,
              y: 13,
              name: "2014-02-21",
              color: "#5E187F",
              mean: 14,
              max: 21,
              min: 8
            },
            {
              x: 1393027200000,
              y: 11,
              name: "2014-02-22",
              color: "#301164",
              mean: 13,
              max: 19,
              min: 8
            },
            {
              x: 1393113600000,
              y: 9,
              name: "2014-02-23",
              color: "#301164",
              mean: 13,
              max: 17,
              min: 8
            },
            {
              x: 1393200000000,
              y: 15,
              name: "2014-02-24",
              color: "#5E187F",
              mean: 14,
              max: 22,
              min: 7
            },
            {
              x: 1393286400000,
              y: 8,
              name: "2014-02-25",
              color: "#301164",
              mean: 13,
              max: 17,
              min: 9
            },
            {
              x: 1393372800000,
              y: 4,
              name: "2014-02-26",
              color: "#5E187F",
              mean: 14,
              max: 16,
              min: 12
            },
            {
              x: 1393459200000,
              y: 5,
              name: "2014-02-27",
              color: "#AA337D",
              mean: 16,
              max: 18,
              min: 13
            },
            {
              x: 1393545600000,
              y: 4,
              name: "2014-02-28",
              color: "#5E187F",
              mean: 14,
              max: 16,
              min: 12
            },
            {
              x: 1393632000000,
              y: 5,
              name: "2014-03-01",
              color: "#5E187F",
              mean: 14,
              max: 17,
              min: 12
            },
            {
              x: 1393718400000,
              y: 5,
              name: "2014-03-02",
              color: "#301164",
              mean: 13,
              max: 16,
              min: 11
            },
            {
              x: 1393804800000,
              y: 6,
              name: "2014-03-03",
              color: "#301164",
              mean: 13,
              max: 16,
              min: 10
            },
            {
              x: 1393891200000,
              y: 5,
              name: "2014-03-04",
              color: "#5E187F",
              mean: 14,
              max: 17,
              min: 12
            },
            {
              x: 1393977600000,
              y: 7,
              name: "2014-03-05",
              color: "#D6456C",
              mean: 17,
              max: 20,
              min: 13
            },
            {
              x: 1394064000000,
              y: 5,
              name: "2014-03-06",
              color: "#711F81",
              mean: 15,
              max: 17,
              min: 12
            },
            {
              x: 1394150400000,
              y: 9,
              name: "2014-03-07",
              color: "#5E187F",
              mean: 14,
              max: 18,
              min: 9
            },
            {
              x: 1394236800000,
              y: 10,
              name: "2014-03-08",
              color: "#5E187F",
              mean: 14,
              max: 19,
              min: 9
            },
            {
              x: 1394323200000,
              y: 8,
              name: "2014-03-09",
              color: "#F2655C",
              mean: 18,
              max: 22,
              min: 14
            },
            {
              x: 1394409600000,
              y: 6,
              name: "2014-03-10",
              color: "#AA337D",
              mean: 16,
              max: 19,
              min: 13
            },
            {
              x: 1394496000000,
              y: 8,
              name: "2014-03-11",
              color: "#D6456C",
              mean: 17,
              max: 21,
              min: 13
            },
            {
              x: 1394582400000,
              y: 8,
              name: "2014-03-12",
              color: "#F2655C",
              mean: 18,
              max: 22,
              min: 14
            },
            {
              x: 1394668800000,
              y: 12,
              name: "2014-03-13",
              color: "#F2655C",
              mean: 18,
              max: 24,
              min: 12
            },
            {
              x: 1394755200000,
              y: 9,
              name: "2014-03-14",
              color: "#AA337D",
              mean: 16,
              max: 21,
              min: 12
            },
            {
              x: 1394841600000,
              y: 13,
              name: "2014-03-15",
              color: "#F2655C",
              mean: 18,
              max: 24,
              min: 11
            },
            {
              x: 1394928000000,
              y: 9,
              name: "2014-03-16",
              color: "#AA337D",
              mean: 16,
              max: 20,
              min: 11
            },
            {
              x: 1395014400000,
              y: 8,
              name: "2014-03-17",
              color: "#711F81",
              mean: 15,
              max: 19,
              min: 11
            },
            {
              x: 1395100800000,
              y: 13,
              name: "2014-03-18",
              color: "#AA337D",
              mean: 16,
              max: 22,
              min: 9
            },
            {
              x: 1395187200000,
              y: 14,
              name: "2014-03-19",
              color: "#AA337D",
              mean: 16,
              max: 23,
              min: 9
            },
            {
              x: 1395273600000,
              y: 10,
              name: "2014-03-20",
              color: "#AA337D",
              mean: 16,
              max: 21,
              min: 11
            },
            {
              x: 1395360000000,
              y: 9,
              name: "2014-03-21",
              color: "#5E187F",
              mean: 14,
              max: 18,
              min: 9
            },
            {
              x: 1395446400000,
              y: 10,
              name: "2014-03-22",
              color: "#301164",
              mean: 13,
              max: 18,
              min: 8
            },
            {
              x: 1395532800000,
              y: 9,
              name: "2014-03-23",
              color: "#5E187F",
              mean: 14,
              max: 18,
              min: 9
            },
            {
              x: 1395619200000,
              y: 13,
              name: "2014-03-24",
              color: "#AA337D",
              mean: 16,
              max: 22,
              min: 9
            },
            {
              x: 1395705600000,
              y: 8,
              name: "2014-03-25",
              color: "#301164",
              mean: 13,
              max: 17,
              min: 9
            },
            {
              x: 1395792000000,
              y: 5,
              name: "2014-03-26",
              color: "#5E187F",
              mean: 14,
              max: 17,
              min: 12
            },
            {
              x: 1395878400000,
              y: 6,
              name: "2014-03-27",
              color: "#AA337D",
              mean: 16,
              max: 18,
              min: 12
            },
            {
              x: 1395964800000,
              y: 9,
              name: "2014-03-28",
              color: "#D6456C",
              mean: 17,
              max: 22,
              min: 13
            },
            {
              x: 1396051200000,
              y: 4,
              name: "2014-03-29",
              color: "#5E187F",
              mean: 14,
              max: 16,
              min: 12
            },
            {
              x: 1396137600000,
              y: 6,
              name: "2014-03-30",
              color: "#301164",
              mean: 13,
              max: 16,
              min: 10
            },
            {
              x: 1396224000000,
              y: 5,
              name: "2014-03-31",
              color: "#110C2F",
              mean: 12,
              max: 14,
              min: 9
            },
            {
              x: 1396310400000,
              y: 6,
              name: "2014-04-01",
              color: "#110C2F",
              mean: 12,
              max: 15,
              min: 9
            },
            {
              x: 1396396800000,
              y: 8,
              name: "2014-04-02",
              color: "#110C2F",
              mean: 12,
              max: 16,
              min: 8
            },
            {
              x: 1396483200000,
              y: 9,
              name: "2014-04-03",
              color: "#5E187F",
              mean: 14,
              max: 18,
              min: 9
            },
            {
              x: 1396569600000,
              y: 5,
              name: "2014-04-04",
              color: "#301164",
              mean: 13,
              max: 16,
              min: 11
            },
            {
              x: 1396656000000,
              y: 7,
              name: "2014-04-05",
              color: "#5E187F",
              mean: 14,
              max: 17,
              min: 10
            },
            {
              x: 1396742400000,
              y: 13,
              name: "2014-04-06",
              color: "#D6456C",
              mean: 17,
              max: 23,
              min: 10
            },
            {
              x: 1396828800000,
              y: 15,
              name: "2014-04-07",
              color: "#FED698",
              mean: 21,
              max: 28,
              min: 13
            },
            {
              x: 1396915200000,
              y: 13,
              name: "2014-04-08",
              color: "#FD9567",
              mean: 19,
              max: 26,
              min: 13
            },
            {
              x: 1397001600000,
              y: 7,
              name: "2014-04-09",
              color: "#5E187F",
              mean: 14,
              max: 18,
              min: 11
            },
            {
              x: 1397088000000,
              y: 13,
              name: "2014-04-10",
              color: "#AA337D",
              mean: 16,
              max: 22,
              min: 9
            },
            {
              x: 1397174400000,
              y: 6,
              name: "2014-04-11",
              color: "#711F81",
              mean: 15,
              max: 18,
              min: 12
            },
            {
              x: 1397260800000,
              y: 8,
              name: "2014-04-12",
              color: "#711F81",
              mean: 15,
              max: 19,
              min: 11
            },
            {
              x: 1397347200000,
              y: 10,
              name: "2014-04-13",
              color: "#D6456C",
              mean: 17,
              max: 22,
              min: 12
            },
            {
              x: 1397433600000,
              y: 9,
              name: "2014-04-14",
              color: "#AA337D",
              mean: 16,
              max: 20,
              min: 11
            },
            {
              x: 1397520000000,
              y: 7,
              name: "2014-04-15",
              color: "#711F81",
              mean: 15,
              max: 18,
              min: 11
            },
            {
              x: 1397606400000,
              y: 12,
              name: "2014-04-16",
              color: "#D6456C",
              mean: 17,
              max: 23,
              min: 11
            },
            {
              x: 1397692800000,
              y: 6,
              name: "2014-04-17",
              color: "#711F81",
              mean: 15,
              max: 18,
              min: 12
            },
            {
              x: 1397779200000,
              y: 6,
              name: "2014-04-18",
              color: "#5E187F",
              mean: 14,
              max: 17,
              min: 11
            },
            {
              x: 1397865600000,
              y: 6,
              name: "2014-04-19",
              color: "#5E187F",
              mean: 14,
              max: 17,
              min: 11
            },
            {
              x: 1397952000000,
              y: 15,
              name: "2014-04-20",
              color: "#F2655C",
              mean: 18,
              max: 26,
              min: 11
            },
            {
              x: 1398038400000,
              y: 10,
              name: "2014-04-21",
              color: "#AA337D",
              mean: 16,
              max: 21,
              min: 11
            },
            {
              x: 1398124800000,
              y: 6,
              name: "2014-04-22",
              color: "#5E187F",
              mean: 14,
              max: 17,
              min: 11
            },
            {
              x: 1398211200000,
              y: 8,
              name: "2014-04-23",
              color: "#711F81",
              mean: 15,
              max: 19,
              min: 11
            },
            {
              x: 1398297600000,
              y: 6,
              name: "2014-04-24",
              color: "#AA337D",
              mean: 16,
              max: 19,
              min: 13
            },
            {
              x: 1398384000000,
              y: 12,
              name: "2014-04-25",
              color: "#D6456C",
              mean: 17,
              max: 23,
              min: 11
            },
            {
              x: 1398470400000,
              y: 8,
              name: "2014-04-26",
              color: "#301164",
              mean: 13,
              max: 17,
              min: 9
            },
            {
              x: 1398556800000,
              y: 6,
              name: "2014-04-27",
              color: "#711F81",
              mean: 15,
              max: 18,
              min: 12
            },
            {
              x: 1398643200000,
              y: 10,
              name: "2014-04-28",
              color: "#AA337D",
              mean: 16,
              max: 21,
              min: 11
            },
            {
              x: 1398729600000,
              y: 18,
              name: "2014-04-29",
              color: "#FED698",
              mean: 21,
              max: 30,
              min: 12
            },
            {
              x: 1398816000000,
              y: 16,
              name: "2014-04-30",
              color: "#FCF9BB",
              mean: 24,
              max: 32,
              min: 16
            },
            {
              x: 1398902400000,
              y: 13,
              name: "2014-05-01",
              color: "#FCF1B3",
              mean: 23,
              max: 30,
              min: 17
            },
            {
              x: 1398988800000,
              y: 11,
              name: "2014-05-02",
              color: "#F2655C",
              mean: 18,
              max: 23,
              min: 12
            },
            {
              x: 1399075200000,
              y: 6,
              name: "2014-05-03",
              color: "#AA337D",
              mean: 16,
              max: 19,
              min: 13
            },
            {
              x: 1399161600000,
              y: 6,
              name: "2014-05-04",
              color: "#D6456C",
              mean: 17,
              max: 20,
              min: 14
            },
            {
              x: 1399248000000,
              y: 6,
              name: "2014-05-05",
              color: "#AA337D",
              mean: 16,
              max: 19,
              min: 13
            },
            {
              x: 1399334400000,
              y: 8,
              name: "2014-05-06",
              color: "#AA337D",
              mean: 16,
              max: 19,
              min: 11
            },
            {
              x: 1399420800000,
              y: 7,
              name: "2014-05-07",
              color: "#5E187F",
              mean: 14,
              max: 18,
              min: 11
            },
            {
              x: 1399507200000,
              y: 6,
              name: "2014-05-08",
              color: "#AA337D",
              mean: 16,
              max: 18,
              min: 12
            },
            {
              x: 1399593600000,
              y: 7,
              name: "2014-05-09",
              color: "#AA337D",
              mean: 16,
              max: 19,
              min: 12
            },
            {
              x: 1399680000000,
              y: 8,
              name: "2014-05-10",
              color: "#AA337D",
              mean: 16,
              max: 19,
              min: 11
            },
            {
              x: 1399766400000,
              y: 13,
              name: "2014-05-11",
              color: "#D6456C",
              mean: 17,
              max: 24,
              min: 11
            },
            {
              x: 1399852800000,
              y: 18,
              name: "2014-05-12",
              color: "#FEB47B",
              mean: 20,
              max: 29,
              min: 11
            },
            {
              x: 1399939200000,
              y: 18,
              name: "2014-05-13",
              color: "#FCF9BB",
              mean: 24,
              max: 33,
              min: 15
            },
            {
              x: 1400025600000,
              y: 16,
              name: "2014-05-14",
              color: "#FCFABC",
              mean: 25,
              max: 33,
              min: 17
            },
            {
              x: 1400112000000,
              y: 15,
              name: "2014-05-15",
              color: "#FCEDAF",
              mean: 22,
              max: 29,
              min: 14
            },
            {
              x: 1400198400000,
              y: 9,
              name: "2014-05-16",
              color: "#F2655C",
              mean: 18,
              max: 22,
              min: 13
            },
            {
              x: 1400284800000,
              y: 5,
              name: "2014-05-17",
              color: "#D6456C",
              mean: 17,
              max: 19,
              min: 14
            },
            {
              x: 1400371200000,
              y: 6,
              name: "2014-05-18",
              color: "#D6456C",
              mean: 17,
              max: 20,
              min: 14
            },
            {
              x: 1400457600000,
              y: 7,
              name: "2014-05-19",
              color: "#D6456C",
              mean: 17,
              max: 20,
              min: 13
            },
            {
              x: 1400544000000,
              y: 9,
              name: "2014-05-20",
              color: "#F2655C",
              mean: 18,
              max: 22,
              min: 13
            },
            {
              x: 1400630400000,
              y: 9,
              name: "2014-05-21",
              color: "#F2655C",
              mean: 18,
              max: 22,
              min: 13
            },
            {
              x: 1400716800000,
              y: 9,
              name: "2014-05-22",
              color: "#D6456C",
              mean: 17,
              max: 21,
              min: 12
            },
            {
              x: 1400803200000,
              y: 9,
              name: "2014-05-23",
              color: "#D6456C",
              mean: 17,
              max: 21,
              min: 12
            },
            {
              x: 1400889600000,
              y: 6,
              name: "2014-05-24",
              color: "#AA337D",
              mean: 16,
              max: 19,
              min: 13
            },
            {
              x: 1400976000000,
              y: 10,
              name: "2014-05-25",
              color: "#D6456C",
              mean: 17,
              max: 22,
              min: 12
            },
            {
              x: 1401062400000,
              y: 9,
              name: "2014-05-26",
              color: "#F2655C",
              mean: 18,
              max: 22,
              min: 13
            },
            {
              x: 1401148800000,
              y: 8,
              name: "2014-05-27",
              color: "#AA337D",
              mean: 16,
              max: 20,
              min: 12
            },
            {
              x: 1401235200000,
              y: 10,
              name: "2014-05-28",
              color: "#D6456C",
              mean: 17,
              max: 22,
              min: 12
            },
            {
              x: 1401321600000,
              y: 14,
              name: "2014-05-29",
              color: "#FD9567",
              mean: 19,
              max: 26,
              min: 12
            },
            {
              x: 1401408000000,
              y: 7,
              name: "2014-05-30",
              color: "#711F81",
              mean: 15,
              max: 18,
              min: 11
            },
            {
              x: 1401494400000,
              y: 9,
              name: "2014-05-31",
              color: "#AA337D",
              mean: 16,
              max: 20,
              min: 11
            },
            {
              x: 1401580800000,
              y: 11,
              name: "2014-06-01",
              color: "#D6456C",
              mean: 17,
              max: 22,
              min: 11
            },
            {
              x: 1401667200000,
              y: 8,
              name: "2014-06-02",
              color: "#AA337D",
              mean: 16,
              max: 19,
              min: 11
            },
            {
              x: 1401753600000,
              y: 7,
              name: "2014-06-03",
              color: "#AA337D",
              mean: 16,
              max: 19,
              min: 12
            },
            {
              x: 1401840000000,
              y: 8,
              name: "2014-06-04",
              color: "#AA337D",
              mean: 16,
              max: 20,
              min: 12
            },
            {
              x: 1401926400000,
              y: 10,
              name: "2014-06-05",
              color: "#D6456C",
              mean: 17,
              max: 22,
              min: 12
            },
            {
              x: 1402012800000,
              y: 10,
              name: "2014-06-06",
              color: "#D6456C",
              mean: 17,
              max: 22,
              min: 12
            },
            {
              x: 1402099200000,
              y: 9,
              name: "2014-06-07",
              color: "#D6456C",
              mean: 17,
              max: 21,
              min: 12
            },
            {
              x: 1402185600000,
              y: 18,
              name: "2014-06-08",
              color: "#FCEDAF",
              mean: 22,
              max: 31,
              min: 13
            },
            {
              x: 1402272000000,
              y: 11,
              name: "2014-06-09",
              color: "#FEB47B",
              mean: 20,
              max: 25,
              min: 14
            },
            {
              x: 1402358400000,
              y: 9,
              name: "2014-06-10",
              color: "#FD9567",
              mean: 19,
              max: 23,
              min: 14
            },
            {
              x: 1402444800000,
              y: 9,
              name: "2014-06-11",
              color: "#F2655C",
              mean: 18,
              max: 23,
              min: 14
            },
            {
              x: 1402531200000,
              y: 6,
              name: "2014-06-12",
              color: "#D6456C",
              mean: 17,
              max: 19,
              min: 13
            },
            {
              x: 1402617600000,
              y: 11,
              name: "2014-06-13",
              color: "#F2655C",
              mean: 18,
              max: 23,
              min: 12
            },
            {
              x: 1402704000000,
              y: 16,
              name: "2014-06-14",
              color: "#FED698",
              mean: 21,
              max: 29,
              min: 13
            },
            {
              x: 1402790400000,
              y: 8,
              name: "2014-06-15",
              color: "#D6456C",
              mean: 17,
              max: 21,
              min: 13
            },
            {
              x: 1402876800000,
              y: 5,
              name: "2014-06-16",
              color: "#AA337D",
              mean: 16,
              max: 18,
              min: 13
            },
            {
              x: 1402963200000,
              y: 12,
              name: "2014-06-17",
              color: "#F2655C",
              mean: 18,
              max: 24,
              min: 12
            },
            {
              x: 1403049600000,
              y: 17,
              name: "2014-06-18",
              color: "#FCEDAF",
              mean: 22,
              max: 30,
              min: 13
            },
            {
              x: 1403136000000,
              y: 9,
              name: "2014-06-19",
              color: "#F2655C",
              mean: 18,
              max: 22,
              min: 13
            },
            {
              x: 1403222400000,
              y: 11,
              name: "2014-06-20",
              color: "#FD9567",
              mean: 19,
              max: 24,
              min: 13
            },
            {
              x: 1403308800000,
              y: 6,
              name: "2014-06-21",
              color: "#AA337D",
              mean: 16,
              max: 19,
              min: 13
            },
            {
              x: 1403395200000,
              y: 7,
              name: "2014-06-22",
              color: "#D6456C",
              mean: 17,
              max: 20,
              min: 13
            },
            {
              x: 1403481600000,
              y: 9,
              name: "2014-06-23",
              color: "#F2655C",
              mean: 18,
              max: 22,
              min: 13
            },
            {
              x: 1403568000000,
              y: 7,
              name: "2014-06-24",
              color: "#D6456C",
              mean: 17,
              max: 21,
              min: 14
            },
            {
              x: 1403654400000,
              y: 7,
              name: "2014-06-25",
              color: "#F2655C",
              mean: 18,
              max: 21,
              min: 14
            },
            {
              x: 1403740800000,
              y: 9,
              name: "2014-06-26",
              color: "#F2655C",
              mean: 18,
              max: 23,
              min: 14
            },
            {
              x: 1403827200000,
              y: 9,
              name: "2014-06-27",
              color: "#FD9567",
              mean: 19,
              max: 24,
              min: 15
            },
            {
              x: 1403913600000,
              y: 9,
              name: "2014-06-28",
              color: "#FD9567",
              mean: 19,
              max: 23,
              min: 14
            },
            {
              x: 1404000000000,
              y: 13,
              name: "2014-06-29",
              color: "#FED698",
              mean: 21,
              max: 27,
              min: 14
            },
            {
              x: 1404086400000,
              y: 13,
              name: "2014-06-30",
              color: "#FCEDAF",
              mean: 22,
              max: 28,
              min: 15
            },
            {
              x: 1404172800000,
              y: 10,
              name: "2014-07-01",
              color: "#FD9567",
              mean: 19,
              max: 24,
              min: 14
            },
            {
              x: 1404259200000,
              y: 10,
              name: "2014-07-02",
              color: "#FD9567",
              mean: 19,
              max: 24,
              min: 14
            },
            {
              x: 1404345600000,
              y: 9,
              name: "2014-07-03",
              color: "#F2655C",
              mean: 18,
              max: 23,
              min: 14
            },
            {
              x: 1404432000000,
              y: 7,
              name: "2014-07-04",
              color: "#D6456C",
              mean: 17,
              max: 20,
              min: 13
            },
            {
              x: 1404518400000,
              y: 10,
              name: "2014-07-05",
              color: "#D6456C",
              mean: 17,
              max: 22,
              min: 12
            },
            {
              x: 1404604800000,
              y: 9,
              name: "2014-07-06",
              color: "#AA337D",
              mean: 16,
              max: 21,
              min: 12
            },
            {
              x: 1404691200000,
              y: 10,
              name: "2014-07-07",
              color: "#D6456C",
              mean: 17,
              max: 22,
              min: 12
            },
            {
              x: 1404777600000,
              y: 11,
              name: "2014-07-08",
              color: "#FD9567",
              mean: 19,
              max: 24,
              min: 13
            },
            {
              x: 1404864000000,
              y: 9,
              name: "2014-07-09",
              color: "#FD9567",
              mean: 19,
              max: 24,
              min: 15
            },
            {
              x: 1404950400000,
              y: 7,
              name: "2014-07-10",
              color: "#FEB47B",
              mean: 20,
              max: 23,
              min: 16
            },
            {
              x: 1405036800000,
              y: 6,
              name: "2014-07-11",
              color: "#FD9567",
              mean: 19,
              max: 22,
              min: 16
            },
            {
              x: 1405123200000,
              y: 9,
              name: "2014-07-12",
              color: "#D6456C",
              mean: 17,
              max: 21,
              min: 12
            },
            {
              x: 1405209600000,
              y: 8,
              name: "2014-07-13",
              color: "#AA337D",
              mean: 16,
              max: 20,
              min: 12
            },
            {
              x: 1405296000000,
              y: 10,
              name: "2014-07-14",
              color: "#FD9567",
              mean: 19,
              max: 24,
              min: 14
            },
            {
              x: 1405382400000,
              y: 12,
              name: "2014-07-15",
              color: "#FED698",
              mean: 21,
              max: 27,
              min: 15
            },
            {
              x: 1405468800000,
              y: 9,
              name: "2014-07-16",
              color: "#FED698",
              mean: 21,
              max: 26,
              min: 17
            },
            {
              x: 1405555200000,
              y: 6,
              name: "2014-07-17",
              color: "#FED698",
              mean: 21,
              max: 23,
              min: 17
            },
            {
              x: 1405641600000,
              y: 6,
              name: "2014-07-18",
              color: "#FEB47B",
              mean: 20,
              max: 23,
              min: 17
            },
            {
              x: 1405728000000,
              y: 7,
              name: "2014-07-19",
              color: "#FEB47B",
              mean: 20,
              max: 23,
              min: 16
            },
            {
              x: 1405814400000,
              y: 12,
              name: "2014-07-20",
              color: "#FEB47B",
              mean: 20,
              max: 26,
              min: 14
            },
            {
              x: 1405900800000,
              y: 6,
              name: "2014-07-21",
              color: "#FCEDAF",
              mean: 22,
              max: 24,
              min: 18
            },
            {
              x: 1405987200000,
              y: 7,
              name: "2014-07-22",
              color: "#FCEDAF",
              mean: 22,
              max: 25,
              min: 18
            },
            {
              x: 1406073600000,
              y: 6,
              name: "2014-07-23",
              color: "#FED698",
              mean: 21,
              max: 24,
              min: 18
            },
            {
              x: 1406160000000,
              y: 12,
              name: "2014-07-24",
              color: "#FCEDAF",
              mean: 22,
              max: 28,
              min: 16
            },
            {
              x: 1406246400000,
              y: 15,
              name: "2014-07-25",
              color: "#FCF9BB",
              mean: 24,
              max: 32,
              min: 17
            },
            {
              x: 1406332800000,
              y: 9,
              name: "2014-07-26",
              color: "#FED698",
              mean: 21,
              max: 25,
              min: 16
            },
            {
              x: 1406419200000,
              y: 9,
              name: "2014-07-27",
              color: "#FED698",
              mean: 21,
              max: 25,
              min: 16
            },
            {
              x: 1406505600000,
              y: 7,
              name: "2014-07-28",
              color: "#FD9567",
              mean: 19,
              max: 23,
              min: 16
            },
            {
              x: 1406592000000,
              y: 7,
              name: "2014-07-29",
              color: "#FD9567",
              mean: 19,
              max: 23,
              min: 16
            },
            {
              x: 1406678400000,
              y: 8,
              name: "2014-07-30",
              color: "#F2655C",
              mean: 18,
              max: 22,
              min: 14
            },
            {
              x: 1406764800000,
              y: 8,
              name: "2014-07-31",
              color: "#F2655C",
              mean: 18,
              max: 22,
              min: 14
            },
            {
              x: 1406851200000,
              y: 7,
              name: "2014-08-01",
              color: "#FD9567",
              mean: 19,
              max: 22,
              min: 15
            },
            {
              x: 1406937600000,
              y: 6,
              name: "2014-08-02",
              color: "#F2655C",
              mean: 18,
              max: 21,
              min: 15
            },
            {
              x: 1407024000000,
              y: 5,
              name: "2014-08-03",
              color: "#F2655C",
              mean: 18,
              max: 21,
              min: 16
            },
            {
              x: 1407110400000,
              y: 8,
              name: "2014-08-04",
              color: "#FEB47B",
              mean: 20,
              max: 24,
              min: 16
            },
            {
              x: 1407196800000,
              y: 6,
              name: "2014-08-05",
              color: "#FEB47B",
              mean: 20,
              max: 23,
              min: 17
            },
            {
              x: 1407283200000,
              y: 9,
              name: "2014-08-06",
              color: "#FED698",
              mean: 21,
              max: 25,
              min: 16
            },
            {
              x: 1407369600000,
              y: 5,
              name: "2014-08-07",
              color: "#F2655C",
              mean: 18,
              max: 21,
              min: 16
            },
            {
              x: 1407456000000,
              y: 7,
              name: "2014-08-08",
              color: "#FD9567",
              mean: 19,
              max: 23,
              min: 16
            },
            {
              x: 1407542400000,
              y: 6,
              name: "2014-08-09",
              color: "#F2655C",
              mean: 18,
              max: 21,
              min: 15
            },
            {
              x: 1407628800000,
              y: 9,
              name: "2014-08-10",
              color: "#FED698",
              mean: 21,
              max: 25,
              min: 16
            },
            {
              x: 1407715200000,
              y: 10,
              name: "2014-08-11",
              color: "#FED698",
              mean: 21,
              max: 26,
              min: 16
            },
            {
              x: 1407801600000,
              y: 8,
              name: "2014-08-12",
              color: "#FED698",
              mean: 21,
              max: 25,
              min: 17
            },
            {
              x: 1407888000000,
              y: 9,
              name: "2014-08-13",
              color: "#FED698",
              mean: 21,
              max: 25,
              min: 16
            },
            {
              x: 1407974400000,
              y: 7,
              name: "2014-08-14",
              color: "#FD9567",
              mean: 19,
              max: 23,
              min: 16
            },
            {
              x: 1408060800000,
              y: 7,
              name: "2014-08-15",
              color: "#FD9567",
              mean: 19,
              max: 23,
              min: 16
            },
            {
              x: 1408147200000,
              y: 8,
              name: "2014-08-16",
              color: "#FD9567",
              mean: 19,
              max: 23,
              min: 15
            },
            {
              x: 1408233600000,
              y: 8,
              name: "2014-08-17",
              color: "#F2655C",
              mean: 18,
              max: 22,
              min: 14
            },
            {
              x: 1408320000000,
              y: 5,
              name: "2014-08-18",
              color: "#F2655C",
              mean: 18,
              max: 21,
              min: 16
            },
            {
              x: 1408406400000,
              y: 8,
              name: "2014-08-19",
              color: "#FEB47B",
              mean: 20,
              max: 24,
              min: 16
            },
            {
              x: 1408492800000,
              y: 6,
              name: "2014-08-20",
              color: "#FEB47B",
              mean: 20,
              max: 23,
              min: 17
            },
            {
              x: 1408579200000,
              y: 7,
              name: "2014-08-21",
              color: "#FEB47B",
              mean: 20,
              max: 23,
              min: 16
            },
            {
              x: 1408665600000,
              y: 10,
              name: "2014-08-22",
              color: "#FEB47B",
              mean: 20,
              max: 25,
              min: 15
            },
            {
              x: 1408752000000,
              y: 10,
              name: "2014-08-23",
              color: "#FD9567",
              mean: 19,
              max: 24,
              min: 14
            },
            {
              x: 1408838400000,
              y: 10,
              name: "2014-08-24",
              color: "#FD9567",
              mean: 19,
              max: 24,
              min: 14
            },
            {
              x: 1408924800000,
              y: 7,
              name: "2014-08-25",
              color: "#FEB47B",
              mean: 20,
              max: 23,
              min: 16
            },
            {
              x: 1409011200000,
              y: 8,
              name: "2014-08-26",
              color: "#FD9567",
              mean: 19,
              max: 23,
              min: 15
            },
            {
              x: 1409097600000,
              y: 7,
              name: "2014-08-27",
              color: "#FD9567",
              mean: 19,
              max: 23,
              min: 16
            },
            {
              x: 1409184000000,
              y: 8,
              name: "2014-08-28",
              color: "#FD9567",
              mean: 19,
              max: 23,
              min: 15
            },
            {
              x: 1409270400000,
              y: 6,
              name: "2014-08-29",
              color: "#FD9567",
              mean: 19,
              max: 22,
              min: 16
            },
            {
              x: 1409356800000,
              y: 10,
              name: "2014-08-30",
              color: "#FCEDAF",
              mean: 22,
              max: 27,
              min: 17
            },
            {
              x: 1409443200000,
              y: 7,
              name: "2014-08-31",
              color: "#FED698",
              mean: 21,
              max: 24,
              min: 17
            },
            {
              x: 1409529600000,
              y: 12,
              name: "2014-09-01",
              color: "#FCEDAF",
              mean: 22,
              max: 28,
              min: 16
            },
            {
              x: 1409616000000,
              y: 7,
              name: "2014-09-02",
              color: "#FD9567",
              mean: 19,
              max: 23,
              min: 16
            },
            {
              x: 1409702400000,
              y: 8,
              name: "2014-09-03",
              color: "#FEB47B",
              mean: 20,
              max: 24,
              min: 16
            },
            {
              x: 1409788800000,
              y: 8,
              name: "2014-09-04",
              color: "#FEB47B",
              mean: 20,
              max: 24,
              min: 16
            },
            {
              x: 1409875200000,
              y: 8,
              name: "2014-09-05",
              color: "#FEB47B",
              mean: 20,
              max: 24,
              min: 16
            },
            {
              x: 1409961600000,
              y: 7,
              name: "2014-09-06",
              color: "#FD9567",
              mean: 19,
              max: 22,
              min: 15
            },
            {
              x: 1410048000000,
              y: 8,
              name: "2014-09-07",
              color: "#F2655C",
              mean: 18,
              max: 22,
              min: 14
            },
            {
              x: 1410134400000,
              y: 6,
              name: "2014-09-08",
              color: "#D6456C",
              mean: 17,
              max: 20,
              min: 14
            },
            {
              x: 1410220800000,
              y: 7,
              name: "2014-09-09",
              color: "#F2655C",
              mean: 18,
              max: 22,
              min: 15
            },
            {
              x: 1410307200000,
              y: 15,
              name: "2014-09-10",
              color: "#FED698",
              mean: 21,
              max: 28,
              min: 13
            },
            {
              x: 1410393600000,
              y: 11,
              name: "2014-09-11",
              color: "#FED698",
              mean: 21,
              max: 26,
              min: 15
            },
            {
              x: 1410480000000,
              y: 10,
              name: "2014-09-12",
              color: "#FD9567",
              mean: 19,
              max: 24,
              min: 14
            },
            {
              x: 1410566400000,
              y: 8,
              name: "2014-09-13",
              color: "#FEB47B",
              mean: 20,
              max: 24,
              min: 16
            },
            {
              x: 1410652800000,
              y: 8,
              name: "2014-09-14",
              color: "#FD9567",
              mean: 19,
              max: 23,
              min: 15
            },
            {
              x: 1410739200000,
              y: 9,
              name: "2014-09-15",
              color: "#FED698",
              mean: 21,
              max: 26,
              min: 17
            },
            {
              x: 1410825600000,
              y: 10,
              name: "2014-09-16",
              color: "#FCEDAF",
              mean: 22,
              max: 27,
              min: 17
            },
            {
              x: 1410912000000,
              y: 11,
              name: "2014-09-17",
              color: "#FCEDAF",
              mean: 22,
              max: 28,
              min: 17
            },
            {
              x: 1410998400000,
              y: 9,
              name: "2014-09-18",
              color: "#FCEDAF",
              mean: 22,
              max: 27,
              min: 18
            },
            {
              x: 1411084800000,
              y: 6,
              name: "2014-09-19",
              color: "#FED698",
              mean: 21,
              max: 23,
              min: 17
            },
            {
              x: 1411171200000,
              y: 7,
              name: "2014-09-20",
              color: "#FCEDAF",
              mean: 22,
              max: 25,
              min: 18
            },
            {
              x: 1411257600000,
              y: 4,
              name: "2014-09-21",
              color: "#FED698",
              mean: 21,
              max: 22,
              min: 18
            },
            {
              x: 1411344000000,
              y: 8,
              name: "2014-09-22",
              color: "#FCEDAF",
              mean: 22,
              max: 26,
              min: 18
            },
            {
              x: 1411430400000,
              y: 7,
              name: "2014-09-23",
              color: "#FCEDAF",
              mean: 22,
              max: 25,
              min: 18
            },
            {
              x: 1411516800000,
              y: 9,
              name: "2014-09-24",
              color: "#FCEDAF",
              mean: 22,
              max: 27,
              min: 18
            },
            {
              x: 1411603200000,
              y: 7,
              name: "2014-09-25",
              color: "#FEB47B",
              mean: 20,
              max: 23,
              min: 16
            },
            {
              x: 1411689600000,
              y: 6,
              name: "2014-09-26",
              color: "#FEB47B",
              mean: 20,
              max: 23,
              min: 17
            },
            {
              x: 1411776000000,
              y: 6,
              name: "2014-09-27",
              color: "#FEB47B",
              mean: 20,
              max: 23,
              min: 17
            },
            {
              x: 1411862400000,
              y: 8,
              name: "2014-09-28",
              color: "#FED698",
              mean: 21,
              max: 24,
              min: 16
            },
            {
              x: 1411948800000,
              y: 6,
              name: "2014-09-29",
              color: "#FD9567",
              mean: 19,
              max: 22,
              min: 16
            },
            {
              x: 1412035200000,
              y: 7,
              name: "2014-09-30",
              color: "#FED698",
              mean: 21,
              max: 24,
              min: 17
            },
            {
              x: 1412121600000,
              y: 14,
              name: "2014-10-01",
              color: "#FCF1B3",
              mean: 23,
              max: 30,
              min: 16
            },
            {
              x: 1412208000000,
              y: 17,
              name: "2014-10-02",
              color: "#FCF9BB",
              mean: 24,
              max: 33,
              min: 16
            },
            {
              x: 1412294400000,
              y: 16,
              name: "2014-10-03",
              color: "#FCFDBF",
              mean: 27,
              max: 35,
              min: 19
            },
            {
              x: 1412380800000,
              y: 15,
              name: "2014-10-04",
              color: "#FCFBBD",
              mean: 26,
              max: 33,
              min: 18
            },
            {
              x: 1412467200000,
              y: 15,
              name: "2014-10-05",
              color: "#FCF1B3",
              mean: 23,
              max: 31,
              min: 16
            },
            {
              x: 1412553600000,
              y: 14,
              name: "2014-10-06",
              color: "#FCEDAF",
              mean: 22,
              max: 28,
              min: 14
            },
            {
              x: 1412640000000,
              y: 8,
              name: "2014-10-07",
              color: "#FD9567",
              mean: 19,
              max: 23,
              min: 15
            },
            {
              x: 1412726400000,
              y: 12,
              name: "2014-10-08",
              color: "#FEB47B",
              mean: 20,
              max: 26,
              min: 14
            },
            {
              x: 1412812800000,
              y: 5,
              name: "2014-10-09",
              color: "#F2655C",
              mean: 18,
              max: 20,
              min: 15
            },
            {
              x: 1412899200000,
              y: 6,
              name: "2014-10-10",
              color: "#F2655C",
              mean: 18,
              max: 21,
              min: 15
            },
            {
              x: 1412985600000,
              y: 9,
              name: "2014-10-11",
              color: "#FEB47B",
              mean: 20,
              max: 24,
              min: 15
            },
            {
              x: 1413072000000,
              y: 18,
              name: "2014-10-12",
              color: "#FCF9BB",
              mean: 24,
              max: 33,
              min: 15
            },
            {
              x: 1413158400000,
              y: 14,
              name: "2014-10-13",
              color: "#FCF9BB",
              mean: 24,
              max: 31,
              min: 17
            },
            {
              x: 1413244800000,
              y: 6,
              name: "2014-10-14",
              color: "#FED698",
              mean: 21,
              max: 23,
              min: 17
            },
            {
              x: 1413331200000,
              y: 7,
              name: "2014-10-15",
              color: "#FED698",
              mean: 21,
              max: 24,
              min: 17
            },
            {
              x: 1413417600000,
              y: 9,
              name: "2014-10-16",
              color: "#FD9567",
              mean: 19,
              max: 23,
              min: 14
            },
            {
              x: 1413504000000,
              y: 11,
              name: "2014-10-17",
              color: "#FD9567",
              mean: 19,
              max: 25,
              min: 14
            },
            {
              x: 1413590400000,
              y: 8,
              name: "2014-10-18",
              color: "#FCEDAF",
              mean: 22,
              max: 26,
              min: 18
            },
            {
              x: 1413676800000,
              y: 7,
              name: "2014-10-19",
              color: "#FEB47B",
              mean: 20,
              max: 23,
              min: 16
            },
            {
              x: 1413763200000,
              y: 5,
              name: "2014-10-20",
              color: "#FD9567",
              mean: 19,
              max: 22,
              min: 17
            },
            {
              x: 1413849600000,
              y: 9,
              name: "2014-10-21",
              color: "#F2655C",
              mean: 18,
              max: 22,
              min: 13
            },
            {
              x: 1413936000000,
              y: 9,
              name: "2014-10-22",
              color: "#FD9567",
              mean: 19,
              max: 23,
              min: 14
            },
            {
              x: 1414022400000,
              y: 6,
              name: "2014-10-23",
              color: "#FED698",
              mean: 21,
              max: 23,
              min: 17
            },
            {
              x: 1414108800000,
              y: 7,
              name: "2014-10-24",
              color: "#FD9567",
              mean: 19,
              max: 23,
              min: 16
            },
            {
              x: 1414195200000,
              y: 6,
              name: "2014-10-25",
              color: "#FEB47B",
              mean: 20,
              max: 23,
              min: 17
            },
            {
              x: 1414281600000,
              y: 7,
              name: "2014-10-26",
              color: "#F2655C",
              mean: 18,
              max: 21,
              min: 14
            },
            {
              x: 1414368000000,
              y: 8,
              name: "2014-10-27",
              color: "#D6456C",
              mean: 17,
              max: 21,
              min: 13
            },
            {
              x: 1414454400000,
              y: 9,
              name: "2014-10-28",
              color: "#D6456C",
              mean: 17,
              max: 22,
              min: 13
            },
            {
              x: 1414540800000,
              y: 11,
              name: "2014-10-29",
              color: "#FCEDAF",
              mean: 22,
              max: 27,
              min: 16
            },
            {
              x: 1414627200000,
              y: 7,
              name: "2014-10-30",
              color: "#FD9567",
              mean: 19,
              max: 23,
              min: 16
            },
            {
              x: 1414713600000,
              y: 4,
              name: "2014-10-31",
              color: "#AA337D",
              mean: 16,
              max: 18,
              min: 14
            },
            {
              x: 1414800000000,
              y: 5,
              name: "2014-11-01",
              color: "#AA337D",
              mean: 16,
              max: 18,
              min: 13
            },
            {
              x: 1414886400000,
              y: 10,
              name: "2014-11-02",
              color: "#5E187F",
              mean: 14,
              max: 19,
              min: 9
            },
            {
              x: 1414972800000,
              y: 11,
              name: "2014-11-03",
              color: "#AA337D",
              mean: 16,
              max: 21,
              min: 10
            },
            {
              x: 1415059200000,
              y: 12,
              name: "2014-11-04",
              color: "#AA337D",
              mean: 16,
              max: 22,
              min: 10
            },
            {
              x: 1415145600000,
              y: 12,
              name: "2014-11-05",
              color: "#F2655C",
              mean: 18,
              max: 24,
              min: 12
            },
            {
              x: 1415232000000,
              y: 10,
              name: "2014-11-06",
              color: "#F2655C",
              mean: 18,
              max: 23,
              min: 13
            },
            {
              x: 1415318400000,
              y: 9,
              name: "2014-11-07",
              color: "#D6456C",
              mean: 17,
              max: 21,
              min: 12
            },
            {
              x: 1415404800000,
              y: 12,
              name: "2014-11-08",
              color: "#F2655C",
              mean: 18,
              max: 24,
              min: 12
            },
            {
              x: 1415491200000,
              y: 9,
              name: "2014-11-09",
              color: "#AA337D",
              mean: 16,
              max: 21,
              min: 12
            },
            {
              x: 1415577600000,
              y: 8,
              name: "2014-11-10",
              color: "#AA337D",
              mean: 16,
              max: 20,
              min: 12
            },
            {
              x: 1415664000000,
              y: 7,
              name: "2014-11-11",
              color: "#AA337D",
              mean: 16,
              max: 19,
              min: 12
            },
            {
              x: 1415750400000,
              y: 5,
              name: "2014-11-12",
              color: "#D6456C",
              mean: 17,
              max: 19,
              min: 14
            },
            {
              x: 1415836800000,
              y: 6,
              name: "2014-11-13",
              color: "#D6456C",
              mean: 17,
              max: 19,
              min: 13
            },
            {
              x: 1415923200000,
              y: 6,
              name: "2014-11-14",
              color: "#AA337D",
              mean: 16,
              max: 19,
              min: 13
            },
            {
              x: 1416009600000,
              y: 7,
              name: "2014-11-15",
              color: "#AA337D",
              mean: 16,
              max: 19,
              min: 12
            },
            {
              x: 1416096000000,
              y: 4,
              name: "2014-11-16",
              color: "#AA337D",
              mean: 16,
              max: 17,
              min: 13
            },
            {
              x: 1416182400000,
              y: 9,
              name: "2014-11-17",
              color: "#5E187F",
              mean: 14,
              max: 19,
              min: 10
            },
            {
              x: 1416268800000,
              y: 7,
              name: "2014-11-18",
              color: "#5E187F",
              mean: 14,
              max: 18,
              min: 11
            },
            {
              x: 1416355200000,
              y: 5,
              name: "2014-11-19",
              color: "#AA337D",
              mean: 16,
              max: 18,
              min: 13
            },
            {
              x: 1416441600000,
              y: 4,
              name: "2014-11-20",
              color: "#5E187F",
              mean: 14,
              max: 16,
              min: 12
            },
            {
              x: 1416528000000,
              y: 4,
              name: "2014-11-21",
              color: "#5E187F",
              mean: 14,
              max: 16,
              min: 12
            },
            {
              x: 1416614400000,
              y: 5,
              name: "2014-11-22",
              color: "#AA337D",
              mean: 16,
              max: 18,
              min: 13
            },
            {
              x: 1416700800000,
              y: 10,
              name: "2014-11-23",
              color: "#5E187F",
              mean: 14,
              max: 19,
              min: 9
            },
            {
              x: 1416787200000,
              y: 11,
              name: "2014-11-24",
              color: "#5E187F",
              mean: 14,
              max: 19,
              min: 8
            },
            {
              x: 1416873600000,
              y: 9,
              name: "2014-11-25",
              color: "#5E187F",
              mean: 14,
              max: 18,
              min: 9
            },
            {
              x: 1416960000000,
              y: 11,
              name: "2014-11-26",
              color: "#711F81",
              mean: 15,
              max: 20,
              min: 9
            },
            {
              x: 1417046400000,
              y: 8,
              name: "2014-11-27",
              color: "#5E187F",
              mean: 14,
              max: 18,
              min: 10
            },
            {
              x: 1417132800000,
              y: 9,
              name: "2014-11-28",
              color: "#301164",
              mean: 13,
              max: 17,
              min: 8
            },
            {
              x: 1417219200000,
              y: 4,
              name: "2014-11-29",
              color: "#AA337D",
              mean: 16,
              max: 18,
              min: 14
            },
            {
              x: 1417305600000,
              y: 5,
              name: "2014-11-30",
              color: "#5E187F",
              mean: 14,
              max: 17,
              min: 12
            },
            {
              x: 1417392000000,
              y: 4,
              name: "2014-12-01",
              color: "#AA337D",
              mean: 16,
              max: 18,
              min: 14
            },
            {
              x: 1417478400000,
              y: 4,
              name: "2014-12-02",
              color: "#711F81",
              mean: 15,
              max: 17,
              min: 13
            },
            {
              x: 1417564800000,
              y: 4,
              name: "2014-12-03",
              color: "#D6456C",
              mean: 17,
              max: 19,
              min: 15
            },
            {
              x: 1417651200000,
              y: 5,
              name: "2014-12-04",
              color: "#D6456C",
              mean: 17,
              max: 19,
              min: 14
            },
            {
              x: 1417737600000,
              y: 5,
              name: "2014-12-05",
              color: "#D6456C",
              mean: 17,
              max: 19,
              min: 14
            },
            {
              x: 1417824000000,
              y: 5,
              name: "2014-12-06",
              color: "#D6456C",
              mean: 17,
              max: 19,
              min: 14
            },
            {
              x: 1417910400000,
              y: 6,
              name: "2014-12-07",
              color: "#711F81",
              mean: 15,
              max: 18,
              min: 12
            },
            {
              x: 1417996800000,
              y: 7,
              name: "2014-12-08",
              color: "#D6456C",
              mean: 17,
              max: 20,
              min: 13
            },
            {
              x: 1418083200000,
              y: 3,
              name: "2014-12-09",
              color: "#AA337D",
              mean: 16,
              max: 17,
              min: 14
            },
            {
              x: 1418169600000,
              y: 4,
              name: "2014-12-10",
              color: "#D6456C",
              mean: 17,
              max: 18,
              min: 14
            },
            {
              x: 1418256000000,
              y: 8,
              name: "2014-12-11",
              color: "#711F81",
              mean: 15,
              max: 19,
              min: 11
            },
            {
              x: 1418342400000,
              y: 3,
              name: "2014-12-12",
              color: "#301164",
              mean: 13,
              max: 14,
              min: 11
            },
            {
              x: 1418428800000,
              y: 4,
              name: "2014-12-13",
              color: "#060519",
              mean: 11,
              max: 13,
              min: 9
            },
            {
              x: 1418515200000,
              y: 7,
              name: "2014-12-14",
              color: "#301164",
              mean: 13,
              max: 16,
              min: 9
            },
            {
              x: 1418601600000,
              y: 6,
              name: "2014-12-15",
              color: "#5E187F",
              mean: 14,
              max: 17,
              min: 11
            },
            {
              x: 1418688000000,
              y: 7,
              name: "2014-12-16",
              color: "#5E187F",
              mean: 14,
              max: 17,
              min: 10
            },
            {
              x: 1418774400000,
              y: 6,
              name: "2014-12-17",
              color: "#301164",
              mean: 13,
              max: 16,
              min: 10
            },
            {
              x: 1418860800000,
              y: 5,
              name: "2014-12-18",
              color: "#301164",
              mean: 13,
              max: 16,
              min: 11
            },
            {
              x: 1418947200000,
              y: 2,
              name: "2014-12-19",
              color: "#5E187F",
              mean: 14,
              max: 15,
              min: 13
            },
            {
              x: 1419033600000,
              y: 4,
              name: "2014-12-20",
              color: "#711F81",
              mean: 15,
              max: 17,
              min: 13
            },
            {
              x: 1419120000000,
              y: 3,
              name: "2014-12-21",
              color: "#AA337D",
              mean: 16,
              max: 17,
              min: 14
            },
            {
              x: 1419206400000,
              y: 6,
              name: "2014-12-22",
              color: "#AA337D",
              mean: 16,
              max: 18,
              min: 12
            },
            {
              x: 1419292800000,
              y: 9,
              name: "2014-12-23",
              color: "#AA337D",
              mean: 16,
              max: 20,
              min: 11
            },
            {
              x: 1419379200000,
              y: 8,
              name: "2014-12-24",
              color: "#301164",
              mean: 13,
              max: 17,
              min: 9
            },
            {
              x: 1419465600000,
              y: 6,
              name: "2014-12-25",
              color: "#060519",
              mean: 11,
              max: 14,
              min: 8
            },
            {
              x: 1419552000000,
              y: 8,
              name: "2014-12-26",
              color: "#060519",
              mean: 11,
              max: 15,
              min: 7
            },
            {
              x: 1419638400000,
              y: 7,
              name: "2014-12-27",
              color: "#010106",
              mean: 9,
              max: 13,
              min: 6
            },
            {
              x: 1419724800000,
              y: 8,
              name: "2014-12-28",
              color: "#02020C",
              mean: 10,
              max: 14,
              min: 6
            },
            {
              x: 1419811200000,
              y: 6,
              name: "2014-12-29",
              color: "#02020C",
              mean: 10,
              max: 13,
              min: 7
            },
            {
              x: 1419897600000,
              y: 5,
              name: "2014-12-30",
              color: "#060519",
              mean: 11,
              max: 13,
              min: 8
            },
            {
              x: 1419984000000,
              y: 9,
              name: "2014-12-31",
              color: "#02020C",
              mean: 10,
              max: 14,
              min: 5
            }
          ]
        },
        {
          data: [
            {
              x: 1388534400000,
              y: 5
            },
            {
              x: 1388620800000,
              y: 6
            },
            {
              x: 1388707200000,
              y: 7
            },
            {
              x: 1388793600000,
              y: 6
            },
            {
              x: 1388880000000,
              y: 7
            },
            {
              x: 1388966400000,
              y: 7
            },
            {
              x: 1389052800000,
              y: 8
            },
            {
              x: 1389139200000,
              y: 11
            },
            {
              x: 1389225600000,
              y: 11
            },
            {
              x: 1389312000000,
              y: 9
            },
            {
              x: 1389398400000,
              y: 8
            },
            {
              x: 1389484800000,
              y: 8
            },
            {
              x: 1389571200000,
              y: 6
            },
            {
              x: 1389657600000,
              y: 7
            },
            {
              x: 1389744000000,
              y: 9
            },
            {
              x: 1389830400000,
              y: 8
            },
            {
              x: 1389916800000,
              y: 7
            },
            {
              x: 1390003200000,
              y: 6
            },
            {
              x: 1390089600000,
              y: 6
            },
            {
              x: 1390176000000,
              y: 6
            },
            {
              x: 1390262400000,
              y: 6
            },
            {
              x: 1390348800000,
              y: 7
            },
            {
              x: 1390435200000,
              y: 7
            },
            {
              x: 1390521600000,
              y: 8
            },
            {
              x: 1390608000000,
              y: 9
            },
            {
              x: 1390694400000,
              y: 9
            },
            {
              x: 1390780800000,
              y: 9
            },
            {
              x: 1390867200000,
              y: 12
            },
            {
              x: 1390953600000,
              y: 12
            },
            {
              x: 1391040000000,
              y: 11
            },
            {
              x: 1391126400000,
              y: 8
            },
            {
              x: 1391212800000,
              y: 6
            },
            {
              x: 1391299200000,
              y: 8
            },
            {
              x: 1391385600000,
              y: 8
            },
            {
              x: 1391472000000,
              y: 7
            },
            {
              x: 1391558400000,
              y: 6
            },
            {
              x: 1391644800000,
              y: 9
            },
            {
              x: 1391731200000,
              y: 11
            },
            {
              x: 1391817600000,
              y: 12
            },
            {
              x: 1391904000000,
              y: 13
            },
            {
              x: 1391990400000,
              y: 11
            },
            {
              x: 1392076800000,
              y: 9
            },
            {
              x: 1392163200000,
              y: 8
            },
            {
              x: 1392249600000,
              y: 10
            },
            {
              x: 1392336000000,
              y: 13
            },
            {
              x: 1392422400000,
              y: 11
            },
            {
              x: 1392508800000,
              y: 10
            },
            {
              x: 1392595200000,
              y: 8
            },
            {
              x: 1392681600000,
              y: 9
            },
            {
              x: 1392768000000,
              y: 11
            },
            {
              x: 1392854400000,
              y: 7
            },
            {
              x: 1392940800000,
              y: 8
            },
            {
              x: 1393027200000,
              y: 8
            },
            {
              x: 1393113600000,
              y: 8
            },
            {
              x: 1393200000000,
              y: 7
            },
            {
              x: 1393286400000,
              y: 9
            },
            {
              x: 1393372800000,
              y: 12
            },
            {
              x: 1393459200000,
              y: 13
            },
            {
              x: 1393545600000,
              y: 12
            },
            {
              x: 1393632000000,
              y: 12
            },
            {
              x: 1393718400000,
              y: 11
            },
            {
              x: 1393804800000,
              y: 10
            },
            {
              x: 1393891200000,
              y: 12
            },
            {
              x: 1393977600000,
              y: 13
            },
            {
              x: 1394064000000,
              y: 12
            },
            {
              x: 1394150400000,
              y: 9
            },
            {
              x: 1394236800000,
              y: 9
            },
            {
              x: 1394323200000,
              y: 14
            },
            {
              x: 1394409600000,
              y: 13
            },
            {
              x: 1394496000000,
              y: 13
            },
            {
              x: 1394582400000,
              y: 14
            },
            {
              x: 1394668800000,
              y: 12
            },
            {
              x: 1394755200000,
              y: 12
            },
            {
              x: 1394841600000,
              y: 11
            },
            {
              x: 1394928000000,
              y: 11
            },
            {
              x: 1395014400000,
              y: 11
            },
            {
              x: 1395100800000,
              y: 9
            },
            {
              x: 1395187200000,
              y: 9
            },
            {
              x: 1395273600000,
              y: 11
            },
            {
              x: 1395360000000,
              y: 9
            },
            {
              x: 1395446400000,
              y: 8
            },
            {
              x: 1395532800000,
              y: 9
            },
            {
              x: 1395619200000,
              y: 9
            },
            {
              x: 1395705600000,
              y: 9
            },
            {
              x: 1395792000000,
              y: 12
            },
            {
              x: 1395878400000,
              y: 12
            },
            {
              x: 1395964800000,
              y: 13
            },
            {
              x: 1396051200000,
              y: 12
            },
            {
              x: 1396137600000,
              y: 10
            },
            {
              x: 1396224000000,
              y: 9
            },
            {
              x: 1396310400000,
              y: 9
            },
            {
              x: 1396396800000,
              y: 8
            },
            {
              x: 1396483200000,
              y: 9
            },
            {
              x: 1396569600000,
              y: 11
            },
            {
              x: 1396656000000,
              y: 10
            },
            {
              x: 1396742400000,
              y: 10
            },
            {
              x: 1396828800000,
              y: 13
            },
            {
              x: 1396915200000,
              y: 13
            },
            {
              x: 1397001600000,
              y: 11
            },
            {
              x: 1397088000000,
              y: 9
            },
            {
              x: 1397174400000,
              y: 12
            },
            {
              x: 1397260800000,
              y: 11
            },
            {
              x: 1397347200000,
              y: 12
            },
            {
              x: 1397433600000,
              y: 11
            },
            {
              x: 1397520000000,
              y: 11
            },
            {
              x: 1397606400000,
              y: 11
            },
            {
              x: 1397692800000,
              y: 12
            },
            {
              x: 1397779200000,
              y: 11
            },
            {
              x: 1397865600000,
              y: 11
            },
            {
              x: 1397952000000,
              y: 11
            },
            {
              x: 1398038400000,
              y: 11
            },
            {
              x: 1398124800000,
              y: 11
            },
            {
              x: 1398211200000,
              y: 11
            },
            {
              x: 1398297600000,
              y: 13
            },
            {
              x: 1398384000000,
              y: 11
            },
            {
              x: 1398470400000,
              y: 9
            },
            {
              x: 1398556800000,
              y: 12
            },
            {
              x: 1398643200000,
              y: 11
            },
            {
              x: 1398729600000,
              y: 12
            },
            {
              x: 1398816000000,
              y: 16
            },
            {
              x: 1398902400000,
              y: 17
            },
            {
              x: 1398988800000,
              y: 12
            },
            {
              x: 1399075200000,
              y: 13
            },
            {
              x: 1399161600000,
              y: 14
            },
            {
              x: 1399248000000,
              y: 13
            },
            {
              x: 1399334400000,
              y: 11
            },
            {
              x: 1399420800000,
              y: 11
            },
            {
              x: 1399507200000,
              y: 12
            },
            {
              x: 1399593600000,
              y: 12
            },
            {
              x: 1399680000000,
              y: 11
            },
            {
              x: 1399766400000,
              y: 11
            },
            {
              x: 1399852800000,
              y: 11
            },
            {
              x: 1399939200000,
              y: 15
            },
            {
              x: 1400025600000,
              y: 17
            },
            {
              x: 1400112000000,
              y: 14
            },
            {
              x: 1400198400000,
              y: 13
            },
            {
              x: 1400284800000,
              y: 14
            },
            {
              x: 1400371200000,
              y: 14
            },
            {
              x: 1400457600000,
              y: 13
            },
            {
              x: 1400544000000,
              y: 13
            },
            {
              x: 1400630400000,
              y: 13
            },
            {
              x: 1400716800000,
              y: 12
            },
            {
              x: 1400803200000,
              y: 12
            },
            {
              x: 1400889600000,
              y: 13
            },
            {
              x: 1400976000000,
              y: 12
            },
            {
              x: 1401062400000,
              y: 13
            },
            {
              x: 1401148800000,
              y: 12
            },
            {
              x: 1401235200000,
              y: 12
            },
            {
              x: 1401321600000,
              y: 12
            },
            {
              x: 1401408000000,
              y: 11
            },
            {
              x: 1401494400000,
              y: 11
            },
            {
              x: 1401580800000,
              y: 11
            },
            {
              x: 1401667200000,
              y: 11
            },
            {
              x: 1401753600000,
              y: 12
            },
            {
              x: 1401840000000,
              y: 12
            },
            {
              x: 1401926400000,
              y: 12
            },
            {
              x: 1402012800000,
              y: 12
            },
            {
              x: 1402099200000,
              y: 12
            },
            {
              x: 1402185600000,
              y: 13
            },
            {
              x: 1402272000000,
              y: 14
            },
            {
              x: 1402358400000,
              y: 14
            },
            {
              x: 1402444800000,
              y: 14
            },
            {
              x: 1402531200000,
              y: 13
            },
            {
              x: 1402617600000,
              y: 12
            },
            {
              x: 1402704000000,
              y: 13
            },
            {
              x: 1402790400000,
              y: 13
            },
            {
              x: 1402876800000,
              y: 13
            },
            {
              x: 1402963200000,
              y: 12
            },
            {
              x: 1403049600000,
              y: 13
            },
            {
              x: 1403136000000,
              y: 13
            },
            {
              x: 1403222400000,
              y: 13
            },
            {
              x: 1403308800000,
              y: 13
            },
            {
              x: 1403395200000,
              y: 13
            },
            {
              x: 1403481600000,
              y: 13
            },
            {
              x: 1403568000000,
              y: 14
            },
            {
              x: 1403654400000,
              y: 14
            },
            {
              x: 1403740800000,
              y: 14
            },
            {
              x: 1403827200000,
              y: 15
            },
            {
              x: 1403913600000,
              y: 14
            },
            {
              x: 1404000000000,
              y: 14
            },
            {
              x: 1404086400000,
              y: 15
            },
            {
              x: 1404172800000,
              y: 14
            },
            {
              x: 1404259200000,
              y: 14
            },
            {
              x: 1404345600000,
              y: 14
            },
            {
              x: 1404432000000,
              y: 13
            },
            {
              x: 1404518400000,
              y: 12
            },
            {
              x: 1404604800000,
              y: 12
            },
            {
              x: 1404691200000,
              y: 12
            },
            {
              x: 1404777600000,
              y: 13
            },
            {
              x: 1404864000000,
              y: 15
            },
            {
              x: 1404950400000,
              y: 16
            },
            {
              x: 1405036800000,
              y: 16
            },
            {
              x: 1405123200000,
              y: 12
            },
            {
              x: 1405209600000,
              y: 12
            },
            {
              x: 1405296000000,
              y: 14
            },
            {
              x: 1405382400000,
              y: 15
            },
            {
              x: 1405468800000,
              y: 17
            },
            {
              x: 1405555200000,
              y: 17
            },
            {
              x: 1405641600000,
              y: 17
            },
            {
              x: 1405728000000,
              y: 16
            },
            {
              x: 1405814400000,
              y: 14
            },
            {
              x: 1405900800000,
              y: 18
            },
            {
              x: 1405987200000,
              y: 18
            },
            {
              x: 1406073600000,
              y: 18
            },
            {
              x: 1406160000000,
              y: 16
            },
            {
              x: 1406246400000,
              y: 17
            },
            {
              x: 1406332800000,
              y: 16
            },
            {
              x: 1406419200000,
              y: 16
            },
            {
              x: 1406505600000,
              y: 16
            },
            {
              x: 1406592000000,
              y: 16
            },
            {
              x: 1406678400000,
              y: 14
            },
            {
              x: 1406764800000,
              y: 14
            },
            {
              x: 1406851200000,
              y: 15
            },
            {
              x: 1406937600000,
              y: 15
            },
            {
              x: 1407024000000,
              y: 16
            },
            {
              x: 1407110400000,
              y: 16
            },
            {
              x: 1407196800000,
              y: 17
            },
            {
              x: 1407283200000,
              y: 16
            },
            {
              x: 1407369600000,
              y: 16
            },
            {
              x: 1407456000000,
              y: 16
            },
            {
              x: 1407542400000,
              y: 15
            },
            {
              x: 1407628800000,
              y: 16
            },
            {
              x: 1407715200000,
              y: 16
            },
            {
              x: 1407801600000,
              y: 17
            },
            {
              x: 1407888000000,
              y: 16
            },
            {
              x: 1407974400000,
              y: 16
            },
            {
              x: 1408060800000,
              y: 16
            },
            {
              x: 1408147200000,
              y: 15
            },
            {
              x: 1408233600000,
              y: 14
            },
            {
              x: 1408320000000,
              y: 16
            },
            {
              x: 1408406400000,
              y: 16
            },
            {
              x: 1408492800000,
              y: 17
            },
            {
              x: 1408579200000,
              y: 16
            },
            {
              x: 1408665600000,
              y: 15
            },
            {
              x: 1408752000000,
              y: 14
            },
            {
              x: 1408838400000,
              y: 14
            },
            {
              x: 1408924800000,
              y: 16
            },
            {
              x: 1409011200000,
              y: 15
            },
            {
              x: 1409097600000,
              y: 16
            },
            {
              x: 1409184000000,
              y: 15
            },
            {
              x: 1409270400000,
              y: 16
            },
            {
              x: 1409356800000,
              y: 17
            },
            {
              x: 1409443200000,
              y: 17
            },
            {
              x: 1409529600000,
              y: 16
            },
            {
              x: 1409616000000,
              y: 16
            },
            {
              x: 1409702400000,
              y: 16
            },
            {
              x: 1409788800000,
              y: 16
            },
            {
              x: 1409875200000,
              y: 16
            },
            {
              x: 1409961600000,
              y: 15
            },
            {
              x: 1410048000000,
              y: 14
            },
            {
              x: 1410134400000,
              y: 14
            },
            {
              x: 1410220800000,
              y: 15
            },
            {
              x: 1410307200000,
              y: 13
            },
            {
              x: 1410393600000,
              y: 15
            },
            {
              x: 1410480000000,
              y: 14
            },
            {
              x: 1410566400000,
              y: 16
            },
            {
              x: 1410652800000,
              y: 15
            },
            {
              x: 1410739200000,
              y: 17
            },
            {
              x: 1410825600000,
              y: 17
            },
            {
              x: 1410912000000,
              y: 17
            },
            {
              x: 1410998400000,
              y: 18
            },
            {
              x: 1411084800000,
              y: 17
            },
            {
              x: 1411171200000,
              y: 18
            },
            {
              x: 1411257600000,
              y: 18
            },
            {
              x: 1411344000000,
              y: 18
            },
            {
              x: 1411430400000,
              y: 18
            },
            {
              x: 1411516800000,
              y: 18
            },
            {
              x: 1411603200000,
              y: 16
            },
            {
              x: 1411689600000,
              y: 17
            },
            {
              x: 1411776000000,
              y: 17
            },
            {
              x: 1411862400000,
              y: 16
            },
            {
              x: 1411948800000,
              y: 16
            },
            {
              x: 1412035200000,
              y: 17
            },
            {
              x: 1412121600000,
              y: 16
            },
            {
              x: 1412208000000,
              y: 16
            },
            {
              x: 1412294400000,
              y: 19
            },
            {
              x: 1412380800000,
              y: 18
            },
            {
              x: 1412467200000,
              y: 16
            },
            {
              x: 1412553600000,
              y: 14
            },
            {
              x: 1412640000000,
              y: 15
            },
            {
              x: 1412726400000,
              y: 14
            },
            {
              x: 1412812800000,
              y: 15
            },
            {
              x: 1412899200000,
              y: 15
            },
            {
              x: 1412985600000,
              y: 15
            },
            {
              x: 1413072000000,
              y: 15
            },
            {
              x: 1413158400000,
              y: 17
            },
            {
              x: 1413244800000,
              y: 17
            },
            {
              x: 1413331200000,
              y: 17
            },
            {
              x: 1413417600000,
              y: 14
            },
            {
              x: 1413504000000,
              y: 14
            },
            {
              x: 1413590400000,
              y: 18
            },
            {
              x: 1413676800000,
              y: 16
            },
            {
              x: 1413763200000,
              y: 17
            },
            {
              x: 1413849600000,
              y: 13
            },
            {
              x: 1413936000000,
              y: 14
            },
            {
              x: 1414022400000,
              y: 17
            },
            {
              x: 1414108800000,
              y: 16
            },
            {
              x: 1414195200000,
              y: 17
            },
            {
              x: 1414281600000,
              y: 14
            },
            {
              x: 1414368000000,
              y: 13
            },
            {
              x: 1414454400000,
              y: 13
            },
            {
              x: 1414540800000,
              y: 16
            },
            {
              x: 1414627200000,
              y: 16
            },
            {
              x: 1414713600000,
              y: 14
            },
            {
              x: 1414800000000,
              y: 13
            },
            {
              x: 1414886400000,
              y: 9
            },
            {
              x: 1414972800000,
              y: 10
            },
            {
              x: 1415059200000,
              y: 10
            },
            {
              x: 1415145600000,
              y: 12
            },
            {
              x: 1415232000000,
              y: 13
            },
            {
              x: 1415318400000,
              y: 12
            },
            {
              x: 1415404800000,
              y: 12
            },
            {
              x: 1415491200000,
              y: 12
            },
            {
              x: 1415577600000,
              y: 12
            },
            {
              x: 1415664000000,
              y: 12
            },
            {
              x: 1415750400000,
              y: 14
            },
            {
              x: 1415836800000,
              y: 13
            },
            {
              x: 1415923200000,
              y: 13
            },
            {
              x: 1416009600000,
              y: 12
            },
            {
              x: 1416096000000,
              y: 13
            },
            {
              x: 1416182400000,
              y: 10
            },
            {
              x: 1416268800000,
              y: 11
            },
            {
              x: 1416355200000,
              y: 13
            },
            {
              x: 1416441600000,
              y: 12
            },
            {
              x: 1416528000000,
              y: 12
            },
            {
              x: 1416614400000,
              y: 13
            },
            {
              x: 1416700800000,
              y: 9
            },
            {
              x: 1416787200000,
              y: 8
            },
            {
              x: 1416873600000,
              y: 9
            },
            {
              x: 1416960000000,
              y: 9
            },
            {
              x: 1417046400000,
              y: 10
            },
            {
              x: 1417132800000,
              y: 8
            },
            {
              x: 1417219200000,
              y: 14
            },
            {
              x: 1417305600000,
              y: 12
            },
            {
              x: 1417392000000,
              y: 14
            },
            {
              x: 1417478400000,
              y: 13
            },
            {
              x: 1417564800000,
              y: 15
            },
            {
              x: 1417651200000,
              y: 14
            },
            {
              x: 1417737600000,
              y: 14
            },
            {
              x: 1417824000000,
              y: 14
            },
            {
              x: 1417910400000,
              y: 12
            },
            {
              x: 1417996800000,
              y: 13
            },
            {
              x: 1418083200000,
              y: 14
            },
            {
              x: 1418169600000,
              y: 14
            },
            {
              x: 1418256000000,
              y: 11
            },
            {
              x: 1418342400000,
              y: 11
            },
            {
              x: 1418428800000,
              y: 9
            },
            {
              x: 1418515200000,
              y: 9
            },
            {
              x: 1418601600000,
              y: 11
            },
            {
              x: 1418688000000,
              y: 10
            },
            {
              x: 1418774400000,
              y: 10
            },
            {
              x: 1418860800000,
              y: 11
            },
            {
              x: 1418947200000,
              y: 13
            },
            {
              x: 1419033600000,
              y: 13
            },
            {
              x: 1419120000000,
              y: 14
            },
            {
              x: 1419206400000,
              y: 12
            },
            {
              x: 1419292800000,
              y: 11
            },
            {
              x: 1419379200000,
              y: 9
            },
            {
              x: 1419465600000,
              y: 8
            },
            {
              x: 1419552000000,
              y: 7
            },
            {
              x: 1419638400000,
              y: 6
            },
            {
              x: 1419724800000,
              y: 6
            },
            {
              x: 1419811200000,
              y: 7
            },
            {
              x: 1419897600000,
              y: 8
            },
            {
              x: 1419984000000,
              y: 5
            }
          ],
          color: "transparent",
          enableMouseTracking: false
        }
      ],
      tooltip: {
        useHTML: true,
        headerFormat: "<small>{point.x:%d %B, %Y}</small>",
        pointFormat: "<table>\n  <tr>\n    <th>Min</th>\n    <td>{point.min}</td>\n  </tr>\n  <tr>\n    <th>Mean</th>\n    <td>{point.mean}</td>\n  </tr>\n  <tr>\n    <th>Max</th>\n    <td>{point.max}</td>\n  </tr>\n</table>"
      }
    }
  );
});
