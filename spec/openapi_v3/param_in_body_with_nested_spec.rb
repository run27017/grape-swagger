# frozen_string_literal: true

require 'spec_helper'

describe 'moving body/formData Params to definitions' do
  before :all do
    module NestedBodyParamType
      class TheApi < Grape::API
        namespace :simple_nested_params do
          params do
            optional :contact, type: Hash do
              requires :name, type: String, documentation: { desc: 'name', in: 'body' }
              optional :addresses, type: Array do
                requires :street, type: String, documentation: { desc: 'street', in: 'body' }
                requires :postcode, type: String, documentation: { desc: 'postcode', in: 'body' }
                requires :city, type: String, documentation: { desc: 'city', in: 'body' }
                optional :country, type: String, documentation: { desc: 'country', in: 'body' }
              end
            end
          end
          post '/in_body' do
            { 'declared_params' => declared(params) }
          end

          params do
            requires :id, type: Integer
            optional :name, type: String, documentation: { desc: 'name', in: 'body' }
            optional :address, type: Hash do
              optional :street, type: String, documentation: { desc: 'street', in: 'body' }
              optional :postcode, type: String, documentation: { desc: 'postcode', in: 'formData' }
              optional :city, type: String, documentation: { desc: 'city', in: 'body' }
              optional :country, type: String, documentation: { desc: 'country', in: 'body' }
            end
          end
          put '/in_body/:id' do
            { 'declared_params' => declared(params) }
          end
        end

        namespace :multiple_nested_params do
          params do
            optional :contact, type: Hash do
              requires :name, type: String, documentation: { desc: 'name', in: 'body' }
              optional :addresses, type: Array do
                optional :street, type: String, documentation: { desc: 'street', in: 'body' }
                requires :postcode, type: Integer, documentation: { desc: 'postcode', in: 'formData' }
                optional :city, type: String, documentation: { desc: 'city', in: 'body' }
                optional :country, type: String, documentation: { desc: 'country', in: 'body' }
              end
              optional :delivery_address, type: Hash do
                optional :street, type: String, documentation: { desc: 'street', in: 'body' }
                optional :postcode, type: String, documentation: { desc: 'postcode', in: 'formData' }
                optional :city, type: String, documentation: { desc: 'city', in: 'body' }
                optional :country, type: String, documentation: { desc: 'country', in: 'body' }
              end
            end
          end
          post '/in_body' do
            { 'declared_params' => declared(params) }
          end

          params do
            requires :id, type: Integer
            optional :name, type: String, documentation: { desc: 'name', in: 'body' }
            optional :address, type: Hash do
              optional :street, type: String, documentation: { desc: 'street', in: 'body' }
              requires :postcode, type: String, documentation: { desc: 'postcode', in: 'formData' }
              optional :city, type: String, documentation: { desc: 'city', in: 'body' }
              optional :country, type: String, documentation: { desc: 'country', in: 'body' }
            end
            optional :delivery_address, type: Hash do
              optional :street, type: String, documentation: { desc: 'street', in: 'body' }
              optional :postcode, type: String, documentation: { desc: 'postcode', in: 'formData' }
              optional :city, type: String, documentation: { desc: 'city', in: 'body' }
              optional :country, type: String, documentation: { desc: 'country', in: 'body' }
            end
          end
          put '/in_body/:id' do
            { 'declared_params' => declared(params) }
          end
        end

        add_swagger_documentation
      end
    end
  end

  def app
    NestedBodyParamType::TheApi
  end

  describe 'nested body parameters given' do
    subject do
      get '/swagger_doc/simple_nested_params'
      JSON.parse(last_response.body)
    end

    describe 'POST' do
      specify do
        expect(subject['paths']['/simple_nested_params/in_body']['post']['parameters']).to eql(
          [
            { 'name' => 'body', 'in' => 'body', 'required' => true, 'schema' => { '$ref' => '#/components/schemas/postSimpleNestedParamsInBody' } }
          ]
        )
      end

      specify do
        expect(subject['components']['schemas']['postSimpleNestedParamsInBody']).to eql(
          'type' => 'object',
          'properties' => {
            'contact' => {
              'type' => 'object',
              'properties' => {
                'name' => { 'type' => 'string', 'description' => 'name' },
                'addresses' => {
                  'type' => 'array',
                  'items' => {
                    'type' => 'object',
                    'properties' => {
                      'street' => { 'type' => 'string', 'description' => 'street' },
                      'postcode' => { 'type' => 'string', 'description' => 'postcode' },
                      'city' => { 'type' => 'string', 'description' => 'city' },
                      'country' => { 'type' => 'string', 'description' => 'country' }
                    },
                    'required' => %w[street postcode city]
                  }
                }
              },
              'required' => %w[name]
            }
          }
        )
      end
    end

    describe 'PUT' do
      specify do
        expect(subject['paths']['/simple_nested_params/in_body/{id}']['put']['parameters']).to eql(
          [
            { 'in' => 'path', 'name' => 'id', 'schema' => { 'type' => 'integer', 'format' => 'int32' }, 'required' => true },
            { 'name' => 'body', 'in' => 'body', 'required' => true, 'schema' => { '$ref' => '#/components/schemas/putSimpleNestedParamsInBody' } }
          ]
        )
      end

      specify do
        expect(subject['components']['schemas']['putSimpleNestedParamsInBody']).to eql(
          'type' => 'object',
          'properties' => {
            'name' => { 'type' => 'string', 'description' => 'name' },
            'address' => {
              'type' => 'object',
              'properties' => {
                'street' => { 'type' => 'string', 'description' => 'street' },
                'postcode' => { 'type' => 'string', 'description' => 'postcode' },
                'city' => { 'type' => 'string', 'description' => 'city' },
                'country' => { 'type' => 'string', 'description' => 'country' }
              }
            }
          }
        )
      end
    end
  end

  describe 'multiple nested body parameters given' do
    subject do
      get '/swagger_doc/multiple_nested_params'
      JSON.parse(last_response.body)
    end

    describe 'POST' do
      specify do
        expect(subject['paths']['/multiple_nested_params/in_body']['post']['parameters']).to eql(
          [
            {
              'name' => 'body',
              'in' => 'body',
              'required' => true,
              'schema' => { '$ref' => '#/components/schemas/postMultipleNestedParamsInBody' }
            }
          ]
        )
      end

      specify do
        expect(subject['components']['schemas']['postMultipleNestedParamsInBody']).to eql(
          'type' => 'object',
          'properties' => {
            'contact' => {
              'type' => 'object',
              'properties' => {
                'name' => { 'type' => 'string', 'description' => 'name' },
                'addresses' => {
                  'type' => 'array',
                  'items' => {
                    'type' => 'object',
                    'properties' => {
                      'street' => { 'type' => 'string', 'description' => 'street' },
                      'postcode' => { 'type' => 'integer', 'format' => 'int32', 'description' => 'postcode' },
                      'city' => { 'type' => 'string', 'description' => 'city' },
                      'country' => { 'type' => 'string', 'description' => 'country' }
                    },
                    'required' => ['postcode']
                  }
                },
                'delivery_address' => {
                  'type' => 'object',
                  'properties' => {
                    'street' => { 'type' => 'string', 'description' => 'street' },
                    'postcode' => { 'type' => 'string', 'description' => 'postcode' },
                    'city' => { 'type' => 'string', 'description' => 'city' },
                    'country' => { 'type' => 'string', 'description' => 'country' }
                  }
                }
              },
              'required' => %w[name]
            }
          }
        )
      end
    end

    describe 'PUT' do
      specify do
        expect(subject['paths']['/multiple_nested_params/in_body/{id}']['put']['parameters']).to eql(
          [
            { 'in' => 'path', 'name' => 'id', 'schema' => { 'type' => 'integer', 'format' => 'int32' }, 'required' => true },
            { 'name' => 'body', 'in' => 'body', 'required' => true, 'schema' => { '$ref' => '#/components/schemas/putMultipleNestedParamsInBody' } }
          ]
        )
      end

      specify do
        expect(subject['components']['schemas']['putMultipleNestedParamsInBody']).to eql(
          'type' => 'object',
          'properties' => {
            'name' => { 'type' => 'string', 'description' => 'name' },
            'address' => {
              'type' => 'object',
              'properties' => {
                'street' => { 'type' => 'string', 'description' => 'street' },
                'postcode' => { 'type' => 'string', 'description' => 'postcode' },
                'city' => { 'type' => 'string', 'description' => 'city' },
                'country' => { 'type' => 'string', 'description' => 'country' }
              },
              'required' => ['postcode']
            },
            'delivery_address' => {
              'type' => 'object',
              'properties' => {
                'street' => { 'type' => 'string', 'description' => 'street' },
                'postcode' => { 'type' => 'string', 'description' => 'postcode' },
                'city' => { 'type' => 'string', 'description' => 'city' },
                'country' => { 'type' => 'string', 'description' => 'country' }
              }
            }
          }
        )
      end
    end
  end
end
