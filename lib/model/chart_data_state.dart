class ChartDataState<T> {
  bool isLoading;
  String? error;
  List<Map<String, dynamic>> dataPoints;
  List<String> xLabels;
  T? rawData;

  ChartDataState({
    this.isLoading = true,
    this.error,
    this.dataPoints = const [],
    this.xLabels = const [],
    this.rawData,
  });

  void setLoading() {
    isLoading = true;
    error = null;
  }

  void setData(List<Map<String, dynamic>> points, List<String> labels,
      [T? raw]) {
    dataPoints = points;
    xLabels = labels;
    isLoading = false;
    error = null;
    rawData = raw;
  }

  void setError(String errorMessage) {
    error = errorMessage;
    isLoading = false;
    dataPoints = [];
    xLabels = [];
  }
}

class RiwayatDataState<T> {
  bool isLoading;
  String? error;
  List<Map<String, dynamic>> items;
  T? rawData;

  RiwayatDataState({
    this.isLoading = true,
    this.error,
    this.items = const [],
    this.rawData,
  });

  void setLoading() {
    isLoading = true;
    error = null;
  }

  void setData(List<Map<String, dynamic>> newItems, [T? raw]) {
    items = newItems;
    isLoading = false;
    error = null;
    rawData = raw;
  }

  void setError(String errorMessage) {
    error = errorMessage;
    isLoading = false;
    items = [];
  }
}
