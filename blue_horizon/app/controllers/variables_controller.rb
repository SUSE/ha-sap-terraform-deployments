# frozen_string_literal: true

require 'ruby_terraform'

class VariablesController < ApplicationController
  before_action :set_variables

  def show
    return if @variables.attributes.present?

    flash.now[:alert] = 'No variables are defined!'
  end

  def update
    params[:variables][:cluster_labels] ||= {}

    @variables.attributes = variables_params
    if @variables.save
      flash_message = {}
      if params[:button]
        target_path = plan_path
      else
        flash_message = { notice: 'Variables were successfully updated.' }
        target_path = variables_path
      end
      redirect_to target_path, flash: flash_message
    else
      redirect_to variables_path, flash: {
        error: @variables.errors.full_messages
      }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_variables
    @variables = Variable.load
    if @variables.is_a?(Hash) && @variables[:error]
      redirect_to sources_path, flash: {
        error: @variables[:error], warning: 'Please, edit the scripts'
      }
    end
    # exclude variables handled by cluster sizing
    @excluded = Cluster.variable_handlers
    # set region automatically, if possibe
    return unless @variables.respond_to? :region

    region = Region.load
    return unless region.set_by_metadata

    region.save
    @excluded += Region.variable_handlers
  end

  def variables_params
    params.require(:variables).permit(@variables.strong_params)
  end
end
