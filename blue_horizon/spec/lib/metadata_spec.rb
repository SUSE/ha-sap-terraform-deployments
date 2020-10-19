# frozen_string_literal: true

require 'rails_helper'
require 'metadata'

RSpec.describe Metadata, type: :lib do
  let!(:cloud_framework) { Faker::App.name }
  let(:example) { described_class.new(cloud_framework) }

  it 'initializes a cloud attribute' do
    expect(example.cloud).to be(cloud_framework)
  end

  # Test the private interfaces against known parameters in each CSP
  describe 'private metadata functions' do
    context 'when net errors occur' do
      it 'returns nothing' do
        allow_any_instance_of(Net::HTTP).to receive(:request).and_raise('Nope!')
        expect(example.send(:aws_metadata, '')).to eq(nil)
        expect(example.send(:azure_metadata)).to eq(nil)
        expect(example.send(:gcp_metadata, '')).to eq(nil)
      end
    end

    context 'with cloud framework AWS' do
      let!(:cloud_framework) { Rails.configuration.x.cloud_framework = 'aws' }
      let(:mock_token) { Faker::Alphanumeric.alphanumeric(number: 64) }
      # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html
      let!(:aws_imds_token_mock) do
        stub_request(:put, '169.254.169.254:80/latest/api/token')
          .with(headers: { 'X-aws-ec2-metadata-token-ttl-seconds' => /\d+/ })
          .to_return(body: mock_token)
      end
      let(:mock_metadata) { metadata_fixture(cloud_framework) }
      let!(:aws_imds_mock) do
        stub_request(:get, '169.254.169.254:80/latest/meta-data/')
          .with(headers: { 'X-aws-ec2-metadata-token' => mock_token })
          .to_return(body: mock_metadata)
      end

      it 'fetches a token' do
        expect(example.send(:aws_token)).to eq(mock_token)
        expect(aws_imds_token_mock).to have_been_requested
      end

      it 'fetches metadata' do
        expect(example.send(:aws_metadata, '')).to eq(mock_metadata)
        expect(aws_imds_token_mock).to have_been_requested
        expect(aws_imds_mock).to have_been_requested
      end
    end

    context 'with cloud framework Azure' do
      let!(:cloud_framework) { Rails.configuration.x.cloud_framework = 'azure' }
      let(:mock_metadata) { JSON.parse(metadata_fixture(cloud_framework)) }
      # https://docs.microsoft.com/en-us/azure/virtual-machines/linux/instance-metadata-service#usage
      let!(:azure_imds_mock) do
        stub_request(:get, '169.254.169.254:80/metadata/instance')
          .with(
            headers: { 'Metadata' => 'true' },
            query:   { 'api-version' => '2020-06-01' }
          ).to_return(body: metadata_fixture(cloud_framework))
      end

      it 'fetches metadata' do
        expect(example.send(:azure_metadata)).to eq(mock_metadata)
        expect(azure_imds_mock).to have_been_requested
      end
    end

    context 'with cloud framework GCP' do
      let!(:cloud_framework) { Rails.configuration.x.cloud_framework = 'gcp' }
      let(:mock_metadata) { metadata_fixture(cloud_framework) }
      # https://cloud.google.com/compute/docs/storing-retrieving-metadata#querying
      let!(:gcp_imds_mock) do
        stub_request(:get, 'metadata.google.internal:80/computeMetadata/v1/')
          .with(headers: { 'Metadata-Flavor' => 'Google' })
          .to_return(body: mock_metadata)
      end

      it 'fetches metadata' do
        expect(example.send(:gcp_metadata, '')).to eq(mock_metadata)
        expect(gcp_imds_mock).to have_been_requested
      end
    end
  end

  # With that out of the way, mock the private metadata interfaces
  describe 'public interfaces' do
    let(:mock_location) { Faker::Internet.slug }

    context 'with cloud framework AWS' do
      let!(:cloud_framework) { Rails.configuration.x.cloud_framework = 'aws' }

      before do
        allow(example).to receive(:aws_metadata)
          .with('placement/region')
          .and_return(mock_location)
      end

      it 'gets location' do
        expect(example.location).to eq(mock_location)
      end

      it 'returns nothing on error' do
        expect(example).to receive(:aws_metadata).and_raise('Nope!')
        expect(example.location).to eq(nil)
      end
    end

    context 'with cloud framework Azure' do
      let!(:cloud_framework) { Rails.configuration.x.cloud_framework = 'azure' }

      before do
        allow(example).to receive(:azure_metadata).and_return(
          'compute' => { 'location' => mock_location }
        )
      end

      it 'gets location' do
        expect(example.location).to eq(mock_location)
      end

      it 'returns nothing on error' do
        expect(example).to receive(:azure_metadata).and_raise('Nope!')
        expect(example.location).to eq(nil)
      end
    end

    context 'with cloud framework GCP' do
      let!(:cloud_framework) { Rails.configuration.x.cloud_framework = 'gcp' }

      it 'gets location' do
        allow(example).to receive(:gcp_metadata)
          .with('instance/zone')
          .and_return("projects/projectnum/zones/#{mock_location}")
        expect(example.location).to eq(mock_location)
      end

      it 'returns nothing on error' do
        expect(example).to receive(:gcp_metadata).and_raise('Nope!')
        expect(example.location).to eq(nil)
      end
    end

    context 'when in unknown cloud' do
      let!(:cloud_framework) do
        Rails.configuration.x.cloud_framework = Faker::App.name
      end

      it 'returns no location' do
        expect(example.location).to eq(nil)
      end
    end
  end
end
