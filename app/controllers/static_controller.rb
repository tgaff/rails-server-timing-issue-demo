class StaticController < ApplicationController
  # ActionView::Base.logger = nil
  def home
    if params.include? 'no_nesting'
      without_nesting
    else
      with_nesting
    end
    @total_iterations = @primary_iterations * @nested_iterations
  end

  def with_nesting
    @primary_iterations = 1_000
    @nested_iterations = 100
  end

  def without_nesting
    @primary_iterations = 400_000
    @nested_iterations = 0
  end
end
