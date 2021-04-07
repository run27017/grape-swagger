# frozen_string_literal: true

require 'spec_helper'

describe 'response' do
  include_context "#{MODEL_PARSER} swagger example"

  before :all do
    module TheApi
      class ResponseApiModels < Grape::API
        format :json

        desc 'This returns something',
             success: [{ code: 200 }],
             failure: [
               { code: 400, message: 'BadRequest', model: '' },
               { code: 404, message: 'NotFound', model: Entities::ApiError }
             ]
        get '/use-response' do
          { 'declared_params' => declared(params) }
        end

        add_swagger_documentation(models: [Entities::UseResponse])
      end
    end
  end

  def app
    TheApi::ResponseApiModels
  end

  describe 'uses entity as response object implicitly with route name' do
    subject do
      get '/swagger_doc/use-response'
      JSON.parse(last_response.body)
    end

    specify do
      expect(subject['paths']['/use-response']['get']).to eql(
        'summary' => 'This returns something',
        'produces' => ['application/json'],
        'responses' => {
          '200' => { 'description' => 'This returns something' },
          '400' => { 'description' => 'BadRequest' },
          '404' => { 'description' => 'NotFound', 'content' => { 'application/json' => { 'schema' => { '$ref' => '#/components/schemas/ApiError' } } } }
        },
        'tags' => ['use-response'],
        'operationId' => 'getUseResponse'
      )
      expect(subject['components']['schemas']).to eql(swagger_entity_as_response_object)
    end
  end
end
