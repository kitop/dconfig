require 'sinatra/base'
require 'erb'
require 'yaml'
require 'dconfig'
require 'dconfig/version'

if defined? Encoding
  Encoding.default_external = Encoding::UTF_8
end

module Dconfig
  class Server < Sinatra::Base
    dir = File.dirname(File.expand_path(__FILE__))

    set :views,  "#{dir}/server/views"

    if respond_to? :public_folder
      set :public_folder, "#{dir}/server/public"
    else
      set :public, "#{dir}/server/public"
    end

    set :static, true

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html

      def url_path(*path_parts)
        [ path_prefix, path_parts ].join("/").squeeze('/')
      end
      alias_method :u, :url_path

      def path_prefix
        request.env['SCRIPT_NAME']
      end
    end

    def show(page, layout = true)
      response["Cache-Control"] = "max-age=0, private, must-revalidate"
      begin
        erb page.to_sym, {:layout => layout}
      rescue Errno::ECONNREFUSED
        erb :error, {:layout => false}, :error => "Can't connect to Redis!"
      end
    end

    get "/?" do
      @values = Dconfig.get_all
      show :index
    end

    post "/update" do
      params[:delete] && params[:delete].each do |key|
        Dconfig.delete(key)
      end
      if params[:new]
        pairs = params[:new].reject do |index, pair|
          pair["key"].empty? or pair["value"].empty?
        end.map{|k, v| v}.inject({}){|h, obj| h[obj["key"]] = obj["value"]; h}
        Dconfig.mset pairs
      end
      redirect u("/")
    end

    get '/dump' do
      values = Dconfig.get_all
      if defined?(Rails)
        values = { Rails.env => values }
      end

      attachment("#{Dconfig.key}.yml")
      content_type "text/plain"

      values.to_yaml
    end

  end
end
