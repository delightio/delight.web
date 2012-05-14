require 'awesome_print'
require 'typhoeus'
require 'faraday'
require 'yajl'
require 'pry'

class ClientConsole
  LocalHost = 'localhost:3000'
  ProductionHost = 'delightweb.herokuapp.com'
  StagingHost = 'delightweb-staging.herokuapp.com'

  def initialize
    @domain = ProductionHost
    @scheme = "https"
    @prefix = ""
    @headers = {}
    initialize_conn @domain, ""
  end

  def initialize_conn domain, auth_token
    @headers['X-NB-AuthToken'] = auth_token
    @headers.delete 'X-NB-AuthToken' if auth_token.to_s.empty?
    @domain = domain
    @conn = Faraday.new "#{@scheme}://#{@domain}/#{@prefix}",
      :headers => @headers
  end

  def production! auth_token
    initialize_conn ProductionHost, auth_token
  end

  def staging! auth_token
    initialize_conn StagingHost, auth_token
  end

  def local! auth_token
    initialize_conn LocalHost, auth_token
  end

  def parse_response resp
    [ resp.status, resp.body, resp.headers ]
  end

  def method_missing sym, *args, &block
    super(sym, *args, &block) unless sym =~ /^(?:get|put|post|delete)$/

    parse_response(@conn.send sym, *args)
  end
end

ClientConsole.new.pry
