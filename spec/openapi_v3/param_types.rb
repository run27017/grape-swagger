# frozen_string_literal: true

require 'spec_helper'

describe 'Boolean type' do
  def app
    Class.new(Grape::API) do
      format :json

      params do
        requires :a_boolean, type: Grape::API::Boolean
      end
      post :splines do
        { message: 'hi' }
      end

      add_swagger_documentation
    end
  end

  subject do
    get '/swagger_doc/splines'
    expect(last_response.status).to eq 200
    body = JSON.parse last_response.body
    body['paths']['/splines']['post']['parameters']
  end

  it 'converts boolean types' do
    expect(subject).to eq [
      { 'in' => 'formData', 'name' => 'a_boolean', 'schema' => { 'type' => 'boolean' }, 'required' => true }
    ]
  end
end

describe 'Float type' do
  def app
    Class.new(Grape::API) do
      format :json

      params do
        requires :a_float, type: Float
      end
      post :splines do
        { message: 'hi' }
      end

      add_swagger_documentation
    end
  end

  subject do
    get '/swagger_doc/splines'
    expect(last_response.status).to eq 200
    body = JSON.parse last_response.body
    body['paths']['/splines']['post']['parameters'][0]['schema']
  end

  it 'converts float types' do
    expect(subject).to include('type' => 'number', 'format' => 'float')
  end
end

describe 'File type' do
  def app
    Class.new(Grape::API) do
      format :json

      params do
        requires :file, type: File
      end
      post :upload do
        { 'declared_params' => declared(params) }
      end

      add_swagger_documentation
    end
  end

  subject do
    get '/swagger_doc/upload'
    JSON.parse(last_response.body)['paths']['/upload']['post']['parameters'][0]['schema']
  end

  specify do
    expect(subject).to include('type' => 'file')
  end
end
