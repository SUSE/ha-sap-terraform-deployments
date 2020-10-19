# frozen_string_literal: true

# Provide decorations for simplifying vew code around cluster size slider
class ClusterSizeSliderDecorator < SimpleDelegator
  BASELINE_TICKS = [3, 5, 10, 20, 50, 100, 250].freeze

  def slider_data
    {
      slider_ticks:             slider_ticks,
      slider_value:             instance_count,
      slider_scale:             'logarithmic',
      slider_tooltip:           'always',
      slider_tooltip_position:  'bottom',
      step:                     1,
      slider_ticks_snap_bounds: 0.5
    }
  end

  private

  def slider_ticks
    ticks = BASELINE_TICKS.dup
    ticks.delete_if { |tick| tick > max_nodes_allowed }
    ticks << min_nodes_required
    ticks << max_nodes_allowed
    ticks.uniq.sort
  end
end
