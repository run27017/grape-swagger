# frozen_string_literal: true

require 'spec_helper'

describe 'response' do
  include_context "#{MODEL_PARSER} swagger example"

  before :all do
    module TheApi
      class ResponseApiModelsFlatten < Grape::API
        format :json

        desc 'This returns something',
             success: [{ code: 200, model: Entities::UseResponse }],
             failure: [{ code: 400, message: 'BadRequest', model: Entities::ApiError }]
        params do
          requires :in_body_1, type: Integer, documentation: { desc: 'in_body_1', param_type: 'body' }
          optional :in_body_2, type: String, documentation: { desc: 'in_body_2', param_type: 'body' }
          optional :in_body_3, type: String, documentation: { desc: 'in_body_3', param_type: 'body' }
        end
        post '/use-response' do
          { 'declared_params' => declared(params) }
        end

        add_swagger_documentation(models_flatten: true)
      end
    end
  end

  def app
    TheApi::ResponseApiModelsFlatten
  end

  describe 'uses entity as response object implicitly with route name' do
    subject do
      get '/swagger_doc/use-response'
      JSON.parse(last_response.body)
    end

    specify do
      expect(subject['paths']['/use-response']['post']['parameters']).to eql([{
        'name' => 'body',
        'in' => 'body',
        'required' => true,
        'schema' => {
          'type' => 'object',
          'properties' => {
            'in_body_1' => { 'type' => 'integer', 'format' => 'int32', 'description' => 'in_body_1' },
            'in_body_2' => { 'type' => 'string', 'description' => 'in_body_2' },
            'in_body_3' => { 'type' => 'string', 'description' => 'in_body_3' }
          },
          'required' => ['in_body_1']
        }
      }])
      expect(subject['paths']['/use-response']['post']['responses']).to eql(
        '200' => { 'description' => 'This returns something', 'content' => { 'application/json' => { 'schema' => { 'type' => 'object', 'properties' => { 'mock_data' => { 'type' => 'string', 'description' => "it's a mock" } } } } } },
        '400' => { 'description' => 'BadRequest', 'content' => { 'application/json' => { 'schema' => { 'type' => 'object', 'properties' => { 'mock_data' => { 'type' => 'string', 'description' => "it's a mock" } } } } } }
      )
    end
  end
end
