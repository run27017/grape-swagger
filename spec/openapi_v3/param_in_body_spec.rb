# frozen_string_literal: true

require 'spec_helper'

describe 'setting of param type, such as `query`, `path`, `formData`, `body`, `header`' do
  include_context "#{MODEL_PARSER} swagger example"

  before :all do
    module TheApi
      class BodyParamTypeApi < Grape::API
        namespace :wo_entities do
          desc 'post in body /wo entity'
          params do
            requires :in_body_1, type: Integer, documentation: { desc: 'in_body_1', param_type: 'body' }
            optional :in_body_2, type: String, documentation: { desc: 'in_body_2', param_type: 'body' }
            optional :in_body_3, type: String, documentation: { desc: 'in_body_3', param_type: 'body' }
          end
          post '/in_body' do
            { 'declared_params' => declared(params) }
          end

          desc 'put in body /wo entity'
          params do
            requires :key, type: Integer
            optional :in_body_1, type: Integer, documentation: { desc: 'in_body_1', param_type: 'body' }
            optional :in_body_2, type: String, documentation: { desc: 'in_body_2', param_type: 'body' }
            optional :in_body_3, type: String, documentation: { desc: 'in_body_3', param_type: 'body' }
          end
          put '/in_body/:key' do
            { 'declared_params' => declared(params) }
          end
        end

        namespace :with_entities do
          desc 'post in body with entity',
               success: ::Entities::ResponseItem
          params do
            requires :name, type: String, documentation: { desc: 'name', param_type: 'body' }
          end
          post '/in_body' do
            { 'declared_params' => declared(params) }
          end

          desc 'put in body with entity',
               success: ::Entities::ResponseItem
          params do
            requires :id, type: Integer
            optional :name, type: String, documentation: { desc: 'name', param_type: 'body' }
          end
          put '/in_body/:id' do
            { 'declared_params' => declared(params) }
          end
        end

        namespace :with_entity_param do
          desc 'put in body with entity parameter'
          params do
            optional :data, type: ::Entities::NestedModule::ApiResponse, documentation: { desc: 'request data' }
          end
          post do
            { 'declared_params' => declared(params) }
          end
        end

        add_swagger_documentation
      end
    end
  end

  def app
    TheApi::BodyParamTypeApi
  end

  describe 'no entity given' do
    subject do
      get '/swagger_doc/wo_entities'
      JSON.parse(last_response.body)
    end

    specify do
      expect(subject['paths']['/wo_entities/in_body']['post']['parameters']).to eql(
        [
          { 'name' => 'body', 'in' => 'body', 'required' => true, 'schema' => { '$ref' => '#/components/schemas/postWoEntitiesInBody' } }
        ]
      )
    end

    specify do
      expect(subject['components']['schemas']['postWoEntitiesInBody']).to eql(
        'type' => 'object',
        'properties' => {
          'in_body_1' => { 'type' => 'integer', 'format' => 'int32', 'description' => 'in_body_1' },
          'in_body_2' => { 'type' => 'string', 'description' => 'in_body_2' },
          'in_body_3' => { 'type' => 'string', 'description' => 'in_body_3' }
        },
        'required' => ['in_body_1']
      )
    end

    specify do
      expect(subject['paths']['/wo_entities/in_body/{key}']['put']['parameters']).to eql(
        [
          { 'in' => 'path', 'name' => 'key', 'schema' => { 'type' => 'integer', 'format' => 'int32' }, 'required' => true },
          { 'name' => 'body', 'in' => 'body', 'required' => true, 'schema' => { '$ref' => '#/components/schemas/putWoEntitiesInBody' } }
        ]
      )
    end

    specify do
      expect(subject['components']['schemas']['putWoEntitiesInBody']).to eql(
        'type' => 'object',
        'properties' => {
          'in_body_1' => { 'type' => 'integer', 'format' => 'int32', 'description' => 'in_body_1' },
          'in_body_2' => { 'type' => 'string', 'description' => 'in_body_2' },
          'in_body_3' => { 'type' => 'string', 'description' => 'in_body_3' }
        }
      )
    end
  end

  describe 'entity given' do
    subject do
      get '/swagger_doc/with_entities'
      JSON.parse(last_response.body)
    end

    specify do
      expect(subject['paths']['/with_entities/in_body']['post']['parameters']).to eql(
        [
          { 'name' => 'body', 'in' => 'body', 'required' => true, 'schema' => { '$ref' => '#/components/schemas/postWithEntitiesInBody' } }
        ]
      )
    end

    specify do
      expect(subject['components']['schemas']['postWithEntitiesInBody']).to eql(
        'type' => 'object',
        'properties' => {
          'name' => { 'type' => 'string', 'description' => 'name' }
        },
        'required' => ['name']
      )
    end

    specify do
      expect(subject['paths']['/with_entities/in_body/{id}']['put']['parameters']).to eql(
        [
          { 'in' => 'path', 'name' => 'id', 'schema' => { 'type' => 'integer', 'format' => 'int32' }, 'required' => true },
          { 'name' => 'body', 'in' => 'body', 'required' => true, 'schema' => { '$ref' => '#/components/schemas/putWithEntitiesInBody' } }
        ]
      )
    end

    specify do
      expect(subject['components']['schemas']['putWithEntitiesInBody']).to eql(
        'type' => 'object',
        'properties' => {
          'name' => { 'type' => 'string', 'description' => 'name' }
        }
      )
    end
  end

  describe 'complex entity given' do
    let(:request_parameters_definition) do
      [
        {
          'name' => 'body',
          'in' => 'body',
          'required' => true,
          'schema' => {
            '$ref' => '#/components/schemas/postWithEntityParam'
          }
        }
      ]
    end

    let(:request_body_parameters_definition) do
      {
        'type' => 'object',
        'properties' => {
          'data' => {
            'allOf' => ['$ref' => '#/components/schemas/NestedModule_ApiResponse'],
            'description' => 'request data'
          }
        }
      }
    end

    subject do
      get '/swagger_doc/with_entity_param'
      JSON.parse(last_response.body)
    end

    specify do
      expect(subject['paths']['/with_entity_param']['post']['parameters']).to eql(request_parameters_definition)
    end

    specify do
      expect(subject['components']['schemas']['NestedModule_ApiResponse']).not_to be_nil
    end

    specify do
      expect(subject['components']['schemas']['postWithEntityParam']).to eql(request_body_parameters_definition)
    end
  end
end
