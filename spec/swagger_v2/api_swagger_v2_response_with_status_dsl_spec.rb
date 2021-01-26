# frozen_string_literal: true

require 'spec_helper'

describe 'response' do
  include_context "#{MODEL_PARSER} swagger example"

  before :all do
    module TheApi
      class ResponseApiStatusDSL < Grape::API
        format :json

        desc 'This returns something'
        status 200, Entities::UseResponse
        status 400, 'bad request', Entities::ApiError
        status 404, 'not found' do
          expose :code
        end
        get '/use-response-2' do
          { 'declared_params' => declared(params) }
        end

        add_swagger_documentation(models: [Entities::UseResponse])
      end
    end
  end

  def app
    TheApi::ResponseApiStatusDSL
  end

  describe 'uses entity defined by status DSL as response object' do
    subject do
      get '/swagger_doc/use-response-2'
      JSON.parse(last_response.body)
    end

    specify do
      responses = subject['paths']['/use-response-2']['get']['responses']
      expect(responses).to include(
        '200' => { 'description' => '', 'schema' => { '$ref' => '#/definitions/UseResponse' } },
        '400' => { 'description' => 'bad request', 'schema' => { '$ref' => '#/definitions/ApiError' } },
        '404' => { 'description' => 'not found', 'schema' => { '$ref' => a_string_matching(%r{Class_\w+}) } }
      )

      expect(subject['definitions']).to include(swagger_entity_as_response_object)
      expect(subject['definitions'].keys).to include(a_string_matching(/Class_\w+/))
    end
  end
end
