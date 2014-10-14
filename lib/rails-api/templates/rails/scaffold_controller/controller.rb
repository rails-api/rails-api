<% module_namespacing do -%>
class <%= controller_class_name %>Controller < ApplicationController
  before_action <%= ":set_#{singular_table_name}" %>, only: [:show, :update, :destroy]

  # GET <%= route_url %>
  # GET <%= route_url %>.json
  def index
    @<%= plural_table_name %> = <%= orm_class.all(class_name) %>

    render json: <%= "@#{plural_table_name}" %>
  end

  # GET <%= route_url %>/1
  # GET <%= route_url %>/1.json
  def show
    render json: <%= "@#{singular_table_name}" %>
  end

  # POST <%= route_url %>
  # POST <%= route_url %>.json
  def create
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "#{singular_table_name}_params") %>

    if @<%= orm_instance.save %>
      render json: <%= "@#{singular_table_name}" %>, status: :created, location: <%= "@#{singular_table_name}" %>
    else
      render json: <%= "@#{orm_instance.errors}" %>, status: :unprocessable_entity
    end
  end

  # PATCH/PUT <%= route_url %>/1
  # PATCH/PUT <%= route_url %>/1.json
  def update
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>

    if @<%= Rails::API.rails3? ? orm_instance.update_attributes("params[:#{singular_table_name}]") : orm_instance.update("#{singular_table_name}_params") %>
      head :no_content
    else
      render json: <%= "@#{orm_instance.errors}" %>, status: :unprocessable_entity
    end
  end

  # DELETE <%= route_url %>/1
  # DELETE <%= route_url %>/1.json
  def destroy
    @<%= orm_instance.destroy %>

    head :no_content
  end

  private

    def <%= "set_#{singular_table_name}" %>
      @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    end

    def <%= "#{singular_table_name}_params" %>
      <%- if attributes_names.empty? -%>
      params[:<%= singular_table_name %>]
      <%- else -%>
      params.require(:<%= singular_table_name %>).permit(<%= attributes_names.map { |name| ":#{name}" }.join(', ') %>)
      <%- end -%>
    end
end
<% end -%>
