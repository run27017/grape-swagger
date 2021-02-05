# frozen_string_literal: true

require 'spec_helper'

context 'embedded schema' do
  include_context "#{MODEL_PARSER} swagger example"

  before :all do
    module TheApi
      class EmbeddedSchemaApi < Grape::API
        desc 'post in body /wo entity',
           http_codes: [{ code: 200, model: Entities::Something }]
        params do
          requires :in_body_1, type: Integer, documentation: { desc: 'in_body_1', param_type: 'body' }
          optional :in_body_2, type: String, documentation: { desc: 'in_body_2', param_type: 'body' }
          optional :in_body_3, type: String, documentation: { desc: 'in_body_3', param_type: 'body' }
        end

        post '/embedded' do
          { 'declared_params' => declared(params) }
        end

        add_swagger_documentation embedded_schema: true
      end
    end
  end

  def app
    TheApi::EmbeddedSchemaApi
  end

  subject do
    get '/swagger_doc/embedded'
    JSON.parse(last_response.body)
  end

  describe 'parameters' do
    specify do
      expect(subject['paths']['/embedded']['post']['parameters']).to eql(
        [
          { 'name' => 'body', 'in' => 'body', 'required' => true, 'schema' => {
            'type' => 'object',
            'properties' => {
              'in_body_1' => { 'type' => 'integer', 'format' => 'int32', 'description' => 'in_body_1' },
              'in_body_2' => { 'type' => 'string', 'description' => 'in_body_2' },
              'in_body_3' => { 'type' => 'string', 'description' => 'in_body_3' }
            },
            'required' => ['in_body_1']
          } }
        ]
      )
    end
  end

  specify do
    expect(subject['paths']['/embedded']['post']['responses']).to match(
      '200' => {
        'description' => '', 
        'schema' => a_hash_including('type' => 'object')
      }
    )
  end
end
