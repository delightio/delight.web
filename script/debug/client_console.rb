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
    @scheme = "http"
    @prefix = ""
    @headers = {}
    initialize_conn
  end

  def initialize_conn domain=@domain
    @domain = domain
    @conn = Faraday.new "#{@scheme}://#{@domain}/#{@prefix}",
      :headers => @headers
  end

  def production!
    initialize_conn ProductionHost
  end

  def staging!
    initialize_conn StagingHost
  end

  def local!
    initialize_conn LocalHost
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
