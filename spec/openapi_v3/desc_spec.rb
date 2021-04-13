# frozen_string_literal: true

require 'spec_helper'

describe 'desc' do
  describe 'take desc as summary' do
    include_context "#{MODEL_PARSER} swagger example"

    def app
      Class.new(Grape::API) do
        format :json

        desc 'This returns something'
        get '/use-desc' do
          { 'declared_params' => declared(params) }
        end

        add_swagger_documentation
      end
    end

    subject do
      get '/swagger_doc/use-desc'
      JSON.parse(last_response.body)
    end

    specify do
      expect(subject['paths']['/use-desc']['get']).not_to include('description')
      expect(subject['paths']['/use-desc']['get']).to include('summary')
      expect(subject['paths']['/use-desc']['get']['summary']).to eq('This returns something')
    end
  end
end
