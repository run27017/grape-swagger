# frozen_string_literal: true

require 'spec_helper'

describe 'param documentation overrides' do
  def app
    Class.new(Grape::API) do
      format :json

      params do
        requires :input, type: String
      end
      post :action do
        { message: 'hi' }
      end

      params do
        requires :input, type: String, default: '14', documentation: { type: 'email', default: '42' }
      end
      post :action_with_doc do
        { message: 'hi' }
      end

      add_swagger_documentation
    end
  end

  context 'with no documentation hash' do
    subject do
      get '/swagger_doc/action'
      expect(last_response.status).to eq 200
      body = JSON.parse last_response.body
      body['paths']['/action']['post']['parameters']
    end

    it 'reads param type correctly' do
      expect(subject[0]).to include('schema' => { 'type' => 'string' })
    end
  end

  context 'with documentation hash' do
    subject do
      get '/swagger_doc/action_with_doc'
      expect(last_response.status).to eq 200
      body = JSON.parse last_response.body
      body['paths']['/action_with_doc']['post']['parameters']
    end

    it 'reads param type correctly' do
      expect(subject[0]).to include(
        'schema' => {
          'type' => 'string',
          'format' => 'email'
        }
      )
    end
  end
end

describe 'header defined in documentation' do
  def app
    Class.new(Grape::API) do
      format :json

      desc 'Some API', headers: { 'My-Header' => { required: true, description: 'Set this!' } }
      params do
        requires :input, type: String
      end
      post :action do
        { message: 'hi' }
      end

      add_swagger_documentation
    end
  end

  subject do
    get '/swagger_doc/action'
    expect(last_response.status).to eq 200
    body = JSON.parse last_response.body
    body['paths']['/action']['post']['parameters']
  end

  it 'has consistent types' do
    types = subject.map { |param| param['schema']['type'] }
    expect(types).to eq(%w[string string])
  end
end
