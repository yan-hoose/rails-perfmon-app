module ControllerHelpers
  # data comes out randomly ordered (sorting is done on the client side);
  # to test the data, we need to sort it first
  def sort_result_data(result_data)
    result_data.tabular_data.to_a.sort! { |a, b| b.sum <=> a.sum }
  end
end