# frozen_string_literal: true

# utility class for metadata operations
class Metadata
  require 'net/http'
  require 'json'

  attr_reader :cloud

  def initialize(cloud)
    @cloud = cloud
  end

  def location
    case @cloud
    when 'aws'
      aws_metadata('placement/region')
    when 'azure'
      azure_metadata['compute']['location']
    when 'gcp'
      gcp_metadata('instance/zone').split('/').last
    end
  rescue StandardError
    return nil
  end

  private

  def aws_token
    http = Net::HTTP.new('169.254.169.254', 80)
    token_request = Net::HTTP::Put.new('/latest/api/token')
    token_request['X-aws-ec2-metadata-token-ttl-seconds'] = '21600'
    http.request(token_request).body.strip
  end

  def aws_metadata(key)
    @token ||= aws_token
    http = Net::HTTP.new('169.254.169.254', 80)
    metadata_request = Net::HTTP::Get.new("/latest/meta-data/#{key}")
    metadata_request['X-aws-ec2-metadata-token'] = @token
    http.request(metadata_request).body
  rescue StandardError
    return nil
  end

  def azure_metadata
    http = Net::HTTP.new('169.254.169.254', 80)
    request = Net::HTTP::Get.new('/metadata/instance?api-version=2020-06-01')
    request['Metadata'] = 'true'
    JSON.parse(http.request(request).body)
  rescue StandardError
    return nil
  end

  def gcp_metadata(key)
    http = Net::HTTP.new('metadata.google.internal', 80)
    request = Net::HTTP::Get.new("/computeMetadata/v1/#{key}")
    request['Metadata-Flavor'] = 'Google'
    http.request(request).body
  rescue StandardError
    return nil
  end
end
