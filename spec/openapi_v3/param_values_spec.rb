# frozen_string_literal: true

require 'spec_helper'

def first_parameter_info(request, *digs)
  get "/swagger_doc/#{request}"
  expect(last_response.status).to eq 200
  body = JSON.parse last_response.body
  param = body['paths']["/#{request}"]['post']['parameters'][0]
  param = param.dig(*digs) unless digs.empty?
  param
end

describe 'Convert values to enum or Range' do
  def app
    Class.new(Grape::API) do
      format :json

      params do
        requires :letter, type: String, values: %w[a b c]
      end
      post :plain_array do
        { message: 'hi' }
      end

      params do
        requires :letter, type: String, values: proc { %w[d e f] }
      end
      post :array_in_proc do
        { message: 'hi' }
      end

      params do
        requires :letter, type: String, values: 'a'..'z'
      end
      post :range_letter do
        { message: 'hi' }
      end

      params do
        requires :integer, type: Integer, values: -5..5
      end
      post :range_integer do
        { message: 'hi' }
      end

      add_swagger_documentation
    end
  end

  context 'Plain array values' do
    subject(:plain_array) { first_parameter_info('plain_array', 'schema') }

    it 'has values as array in enum' do
      expect(plain_array).to include('enum' => %w[a b c])
    end
  end

  context 'Array in proc values' do
    subject(:array_in_proc) { first_parameter_info('array_in_proc', 'schema') }

    it 'has proc returned values as array in enum' do
      expect(array_in_proc).to include('enum' => %w[d e f])
    end
  end

  context 'Range values' do
    subject(:range_letter) { first_parameter_info('range_letter', 'schema') }

    it 'has letter range values' do
      expect(range_letter.keys).not_to include('enum')
    end

    subject(:range_integer) { first_parameter_info('range_integer') }

    it 'has integer range values' do
      expect(range_integer).to include('minimum' => -5, 'maximum' => 5)
    end
  end
end

describe 'Convert values to enum for float range and not arrays inside a proc', if: GrapeVersion.satisfy?('>= 0.11.0') do
  def app
    Class.new(Grape::API) do
      format :json

      params do
        requires :letter, type: String, values: proc { 'string' }
      end
      post :non_array_in_proc do
        { message: 'hi' }
      end

      params do
        requires :float, type: Float, values: -5.0..5.0
      end
      post :range_float do
        { message: 'hi' }
      end

      add_swagger_documentation
    end
  end

  context 'Non array in proc values' do
    subject(:non_array_in_proc) { first_parameter_info('non_array_in_proc', 'schema') }

    it 'has proc returned value as string in enum' do
      expect(non_array_in_proc).to include('enum' => 'string')
    end
  end

  context 'Range values' do
    subject(:range_float) { first_parameter_info('range_float', 'schema') }

    it 'has float range values as string' do
      expect(range_float).not_to include('enum')
    end
  end
end
