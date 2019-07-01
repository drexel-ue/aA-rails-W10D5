require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'active_support/inflector'
require_relative './session'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, params)
    @req, @res = req, res
    @already_built_response = false
    @params = params.merge(req.params)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise 'no double rendering plz' if already_built_response?
    res.location = url
    res.status = 302
    @already_built_response = true
    self.session.store_session(res)
  end

  
  def render_content(content, content_type)
    raise 'no double rendering plz' if already_built_response?
    res['Content-Type'] = content_type
    res.write(content)
    @already_built_response = true
    @params = content
    self.session.store_session(res)
  end

# use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    template = File.read("views/#{self.class.name.underscore}/#{template_name}.html.erb")
    erb = ERB.new(template).result(binding)
    puts erb
    render_content(erb, 'text/html') 
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    # debugger
    send(name)
    render name
  end
end
