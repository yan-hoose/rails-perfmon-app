$(document).ready(function() {

  var nr_of_requests_chart;
  var avg_request_duration_chart;
  var db_runtime_chart;
  var view_runtime_chart;
  var blocker_count_chart;
  var hour = 1000 * 3600;

  var compare_periods_checkbox = $('#compare-periods-checkbox');
  var comparison_daterange_selector = $('#comparison-daterange');

  var sortable_table = $('#sum_avg_min_max_table').get(0);

  if (sortable_table) {
    new Tablesort(sortable_table, {descending: true});  
  }

  function generateChartsIfPresent() {
    nr_of_requests_chart = $("#nr-of-requests-chart");
    avg_request_duration_chart = $("#avg-request-duration-chart");
    db_runtime_chart = $("#db-runtime-chart");
    view_runtime_chart = $("#view-runtime-chart");
    blocker_count_chart = $("#blocker-count-chart");
    var filters = {
      dashboard: false,
      start_date: $('#start-date').val(),
      end_date: $('#end-date').val(),
      compare_periods: compare_periods_checkbox.prop('checked'),
      comparison_start_date: $('#comparison-start-date').val(),
      comparison_end_date: $('#comparison-end-date').val(),
      contr: $('#controller').val(),
      act: $('#action').val()
    }

    if (nr_of_requests_chart.length > 0) {
      generateNrOfRequestsChart(nr_of_requests_chart.attr('data-website-id'), filters);
    }
    if (avg_request_duration_chart.length > 0) {
      generateAvgRequestDurationChart(avg_request_duration_chart.attr('data-website-id'), filters);
    }
    if (db_runtime_chart.length > 0) {
      generateDbRuntimeChart(db_runtime_chart.attr('data-website-id'), filters);
    }
    if (view_runtime_chart.length > 0) {
      generateViewRuntimeChart(view_runtime_chart.attr('data-website-id'), filters);
    }
    if (blocker_count_chart.length > 0) {
      generateBlockersCountChart(blocker_count_chart.attr('data-website-id'), filters);
    }

    var dashboard_charts = $('.dashboard-chart');
    dashboard_charts.each(function() {
      var chart = $(this);
      generateChart(chart.attr('data-website-id'), 'avg_request_duration_chart', {
        dashboard: true,
        start_date: moment().subtract(2, 'days').format('YYYY-MM-DD'),
        end_date: moment().format('YYYY-MM-DD'),
        compare_periods: false,
        contr: '',
        act: ''
        }, chart, {
          chart: {
            type: 'area'
          },
          title: {
            text: null
          },
          colors: ['#77DD77', '#779ECB', '#FFB347']
        }, function(data_for_series, data_from_source) {
          data_for_series[0].push(data_from_source ? data_from_source.avg_other_runtime : null);
          data_for_series[1].push(data_from_source ? data_from_source.avg_view_runtime : null);
          data_for_series[2].push(data_from_source ? data_from_source.avg_db_runtime : null);
        },
        null,
        {0: 'Avg. other runtime', 1: 'Avg. view runtime', 2: 'Avg. DB runtime'}
      );
    });
  }

  function generateNrOfRequestsChart(website_id, filters) {
    if (filters.compare_periods) {
      generateChart(website_id, 'nr_of_requests_chart', filters, nr_of_requests_chart, {
          chart: {
            type: 'line'
          },
          title: {
            text: 'Amount of requests'
          },
          yAxis: {
            title: {
              text: 'Request count'
            }
          },
          tooltip: {
            shared: true,
            valueSuffix: ''
          },
          colors: ['#779ECB', '#FFB347']
        }, function(data_for_series, data_from_source) {
          data_for_series[0].push(data_from_source ? data_from_source.hits : 0);
        }, function(data_for_series, comparison_data_from_source) {
          data_for_series[1].push(comparison_data_from_source ? comparison_data_from_source.hits : 0);
        },
        {0: 'Request count', 1: 'Comparison request count'}
      );
    } else {
      generateChart(website_id, 'nr_of_requests_chart', filters, nr_of_requests_chart, {
          chart: {
            type: 'line'
          },
          title: {
            text: 'Amount of requests'
          },
          yAxis: {
            title: {
              text: 'Request count'
            }
          },
          tooltip: {
            shared: true,
            valueSuffix: ''
          },
          colors: ['#779ECB']
        }, function(data_for_series, data_from_source) {
          data_for_series[0].push(data_from_source ? data_from_source.hits : 0);
        },
        null,
        {0: 'Request count'}
      );
    }
  }

  function generateBlockersCountChart(website_id, filters) {
    if (filters.compare_periods) {
      generateChart(website_id, 'blocker_count_chart', filters, blocker_count_chart, {
          chart: {
            type: 'line'
          },
          title: {
            text: 'Process blockers'
          },
          yAxis: {
            title: {
              text: 'Blocker count'
            }
          },
          tooltip: {
            shared: true,
            valueSuffix: ''
          },
          colors: ['#779ECB', '#FFB347']
        }, function(data_for_series, data_from_source) {
          data_for_series[0].push(data_from_source ? data_from_source.count : 0);
        }, function(data_for_series, comparison_data_from_source) {
          data_for_series[1].push(comparison_data_from_source ? comparison_data_from_source.count : 0);
        },
        {0: 'Blocker count', 1: 'Comparison period blocker count'}
      );
    } else {
      generateChart(website_id, 'blocker_count_chart', filters, blocker_count_chart, {
          chart: {
            type: 'line'
          },
          title: {
            text: 'Process blockers'
          },
          yAxis: {
            title: {
              text: 'Blocker count'
            }
          },
          tooltip: {
            shared: true,
            valueSuffix: ''
          },
          colors: ['#779ECB']
        }, function(data_for_series, data_from_source) {
          data_for_series[0].push(data_from_source ? data_from_source.count : 0);
        },
        null,
        {0: 'Blocker count'}
      );
    }
  }

  function generateAvgRequestDurationChart(website_id, filters) {
    if (filters.compare_periods) {
      generateChart(website_id, 'avg_request_duration_chart', filters, avg_request_duration_chart, {
          chart: {
            type: 'line'
          },
          title: {
            text: 'Average request runtime'
          },
          colors: ['#779ECB', '#FFB347']
        }, function(data_for_series, data_from_source) {
          data_for_series[0].push(data_from_source ? data_from_source.avg_total_runtime : null);
        }, function(data_for_series, comparison_data_from_source) {
          data_for_series[1].push(comparison_data_from_source ? comparison_data_from_source.avg_total_runtime : null);
        },
        {0: 'Avg. request runtime', 1: 'Avg. comparison runtime'}
      );
    } else {
      generateChart(website_id, 'avg_request_duration_chart', filters, avg_request_duration_chart, {
          chart: {
            type: 'area'
          },
          title: {
            text: 'Average request runtime'
          },
          colors: ['#77DD77', '#779ECB', '#FFB347']
        }, function(data_for_series, data_from_source) {
          data_for_series[0].push(data_from_source ? data_from_source.avg_other_runtime : null);
          data_for_series[1].push(data_from_source ? data_from_source.avg_view_runtime : null);
          data_for_series[2].push(data_from_source ? data_from_source.avg_db_runtime : null);
        },
        null,
        {0: 'Avg. other runtime', 1: 'Avg. view runtime', 2: 'Avg. DB runtime'}
      );
    }
  }

  function generateDbRuntimeChart(website_id, filters) {
    if (filters.compare_periods) {
      generateChart(website_id, 'db_time_chart', filters, db_runtime_chart, {
          chart: {
            type: 'line'
          },
          title: {
            text: 'Average database runtime'
          },
          colors: ['#779ECB', '#FFB347']
        }, function(data_for_series, data_from_source) {
          data_for_series[0].push(data_from_source ? data_from_source.avg_db_runtime : null);
        }, function(data_for_series, comparison_data_from_source) {
          data_for_series[1].push(comparison_data_from_source ? comparison_data_from_source.avg_db_runtime : null);
        },
        {0: 'Avg. DB runtime', 1: 'Avg. comparison runtime'}
      );
    } else {
      generateChart(website_id, 'db_time_chart', filters, db_runtime_chart, {
          chart: {
            type: 'area'
          },
          title: {
            text: 'Average database runtime'
          },
          colors: ['#FFB347']
        }, function(data_for_series, data_from_source) {
          data_for_series[0].push(data_from_source ? data_from_source.avg_db_runtime : null);
        },
        null,
        {0: 'Avg. DB runtime'}
      );
    }
  }

  function generateViewRuntimeChart(website_id, filters) {
    if (filters.compare_periods) {
      generateChart(website_id, 'view_time_chart', filters, view_runtime_chart, {
          chart: {
            type: 'line'
          },
          title: {
            text: 'Average view runtime'
          },
          colors: ['#779ECB', '#FFB347']
        }, function(data_for_series, data_from_source) {
          data_for_series[0].push(data_from_source ? data_from_source.avg_view_runtime : null);
        }, function(data_for_series, comparison_data_from_source) {
          data_for_series[1].push(comparison_data_from_source ? comparison_data_from_source.avg_view_runtime : null);
        },
        {0: 'Avg. view runtime', 1: 'Avg. comparison runtime'}
      );
    } else {
      generateChart(website_id, 'view_time_chart', filters, view_runtime_chart, {
          chart: {
            type: 'area'
          },
          title: {
            text: 'Average view runtime'
          },
          colors: ['#779ECB']
        }, function(data_for_series, data_from_source) {
          data_for_series[0].push(data_from_source ? data_from_source.avg_view_runtime : null);
        },
        null,
        {0: 'Avg. view runtime'}
      );
    }
  }

  function generateChartDataPoints(chart_data, start_time, end_time, data, add_data_callback) {
    var time_index = start_time;
    while (time_index <= end_time) {
      row = data[0];
      if (row && row.timespan * 1000 == time_index) {
        add_data_callback(chart_data, row);
        data.shift();
      } else
        add_data_callback(chart_data, null);
      time_index += hour;
    }
  }

  function generateChart(website_id, action, filters, chart_object, chart_options, add_data_callback, add_comparison_data_callback, series_names) {
    url_params = filtersToUrlParams(filters);

    $.get('/websites/' + website_id + '/reports/' + action + url_params, function(data) {

      // all calculations are in unix timestamps
      var chart_data = {};
      for (var x in series_names)
        chart_data[x] = [];
      var start_time = Date.parse(filters.start_date);
      var end_time = Date.parse(filters.end_date) + 23 * hour;

      generateChartDataPoints(chart_data, start_time, end_time, data.data, add_data_callback);
      if (add_comparison_data_callback)
        generateChartDataPoints(chart_data,
          Date.parse(filters.comparison_start_date), Date.parse(filters.comparison_end_date) + 23 * hour,
          data.comparison_data, add_comparison_data_callback);

      var default_options = {
        xAxis: {
          type: 'datetime',
        },
        yAxis: {
          title: {
            text: 'Avg. runtime (ms)'
          }
        },
        tooltip: {
          shared: true,
          valueSuffix: ' ms'
        },
        legend: {
          enabled: false
        },
        plotOptions: {
          area: {
            stacking: 'normal',
            marker: {
              enabled: false,
              lineWidth: 1
            },
            states: {
              hover: {
                enabled: true,
                lineWidth: 1
              }
            },
            lineWidth: 1,
            pointInterval: 1 * hour,
            pointStart: start_time,
          },
          line: {
            marker: {
              enabled: false,
              radius: 2
            },
            states: {
              hover: {
                enabled: true,
                lineWidth: 2
              }
            },
            lineWidth: 2,
            threshold: 0,
            pointInterval: 1 * hour,
            pointStart: start_time
          },
          spline: {
            marker: {
              enabled: false,
              radius: 2
            },
            states: {
              hover: {
                enabled: true,
                lineWidth: 2
              }
            },
            lineWidth: 2,
            threshold: 0,
            pointInterval: 1 * hour,
            pointStart: start_time
          }
        }           
      };
      var options = $.extend(default_options, chart_options);
      var series = {series: []};
      for (var j in series_names) {
        series.series.push({name: series_names[j], data: chart_data[j]});
      }

      chart_object.highcharts($.extend(options, series));

      getNotes(chart_object, website_id, filters);
    }, 'json');
  }

  function generateChartDataPoints(chart_data, start_time, end_time, data, add_data_callback) {
    var time_index = start_time;
    while (time_index <= end_time) {
      row = data[0];
      if (row && row.timespan * 1000 == time_index) {
        add_data_callback(chart_data, row);
        data.shift();
      } else
        add_data_callback(chart_data, null);
      time_index += hour;
    }
  }

  function getNotes(chart_object, website_id, filters) {
    $.get('/websites/' + website_id + '/notes?start=' + filters.start_date + '&end=' + filters.end_date, function(data) {
      chart = chart_object.highcharts();
      for (var i = 0; i < data.length; i++) {
        var time = Date.parse(data[i].time);
        time += (moment(data[i].time)._tzm / 60) * hour;
        chart.xAxis[0].addPlotLine({
          value: time,
          color: '#428BCA',
          width: 1,
          label: {
            text: '<span class="chart-note-label" data-id="' + data[i].id + '" data-text="' + data[i].text + '">' + data[i].text.substr(0, 10) + '&hellip;</span>',
            useHTML: true,
            style: {
              color: '#C0C0C0',
            },
            y: 3
          }
        });
      }
      chart_object.find('.chart-note-label').mouseover(function(event) {
        displayNote(chart_object, $(this), event);
      }).mouseout(function() {
        hideNote($(this).attr('data-id'));
      });
    }, 'json');    
  }

  function displayNote(chart_object, label_tag, mouse_event) {
    var chart_offset = chart_object.offset();
    var left = mouse_event.pageX + (document.documentElement.scrollLeft || document.body.scrollLeft) - chart_offset.left - 220;
    if (left < 0) left = 0;

    chart_object.append($('<div/>', {
      id: 'note-' + label_tag.attr('data-id'),
      html: label_tag.attr('data-text').replace(/\r?\n/g, '<br/>'),
      class: 'chart-note'
    }).css('left', left));
  }

  function hideNote(note_id) {
    $('#note-' + note_id).remove();
  }

  function applyDateFilters(start, end, compare_periods, comparison_start, comparison_end) {
    $('#daterange span.daterange-str').html(start + ' - ' + end);
    $('#comparison-daterange span.daterange-str').html(comparison_start + ' - ' + comparison_end);

    var filters = {
      start: start,
      end: end,
      compare_periods: compare_periods,
      comparison_start: comparison_start,
      comparison_end: comparison_end,
      contr: $('#controller').val(),
      act: $('#action').val()
    };

    window.location.href = window.location.pathname + filtersToUrlParams(filters);
  }

  function filtersToUrlParams(filters) {
    var url_params = [];

    for (var filter in filters) {
      if (filters[filter] != typeof(undefined))
        url_params.push(filter + '=' + filters[filter]);
    }

    return '?' + url_params.join('&');
  }

  $('#daterange').daterangepicker(
    {
      format: 'YYYY-MM-DD',
      startDate: $('#start-date').val(),
      endDate: $('#end-date').val(),
      locale: {
        firstDay: 1
      },
      ranges: {
         'Last 7 Days': [moment().subtract(6, 'days'), moment()],
         'Last 14 Days': [moment().subtract(13, 'days'), moment()],
         'Last 30 Days': [moment().subtract(29, 'days'), moment()],
         'This Month': [moment().startOf('month'), moment().endOf('month')],
         'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
      }
    },
    function(start, end) {
      applyDateFilters(start.format('YYYY-MM-DD'), end.format('YYYY-MM-DD'), compare_periods_checkbox.prop('checked'),
        $('#comparison-start-date').val(), $('#comparison-end-date').val());
    } 
  );
  $('#daterange').on('apply.daterangepicker', function(ev, picker) {
    applyDateFilters(picker.startDate.format('YYYY-MM-DD'), picker.endDate.format('YYYY-MM-DD'), compare_periods_checkbox.prop('checked'),
      $('#comparison-start-date').val(), $('#comparison-end-date').val());
  });
  $('#comparison-daterange').on('apply.daterangepicker', function(ev, picker) {
    applyDateFilters($('#start-date').val(), $('#end-date').val(), true, picker.startDate.format('YYYY-MM-DD'), picker.endDate.format('YYYY-MM-DD'));
  });

  $('#comparison-daterange').daterangepicker(
    {
      format: 'YYYY-MM-DD',
      startDate: $('#comparison-start-date').val(),
      endDate: $('#comparison-end-date').val(),
      locale: {
        firstDay: 1
      },
      ranges: {
         'Last 7 Days': [moment().subtract(6, 'days'), moment()],
         'Last 14 Days': [moment().subtract(13, 'days'), moment()],
         'Last 30 Days': [moment().subtract(29, 'days'), moment()],
         'This Month': [moment().startOf('month'), moment().endOf('month')],
         'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
      }
    },
    function(comparison_start, comparison_end) {
      applyDateFilters($('#start-date').val(), $('#end-date').val(), true, comparison_start.format('YYYY-MM-DD'), comparison_end.format('YYYY-MM-DD'));
    }
  );

  if(compare_periods_checkbox.prop('checked'))
    comparison_daterange_selector.show();
  else
    comparison_daterange_selector.hide();

  compare_periods_checkbox.change(function() {
    if ($(this).prop('checked'))
      comparison_daterange_selector.slideDown('fast');
    else
      comparison_daterange_selector.slideUp('fast');
  });

  generateChartsIfPresent();

});