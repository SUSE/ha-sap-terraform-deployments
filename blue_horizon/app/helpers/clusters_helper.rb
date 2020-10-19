# frozen_string_literal: true

# Helpers used in cluster sizing
module ClustersHelper
  def instance_types_doc_url_for(framework)
    Rails.configuration.x.external_instance_types_link[framework]
  end
end
