module Lipsiadmin
  module Controller
    module Ext
      # Return column config, and store config/data for ExtJS ColumnModel and Store
      # 
      #   Examples:
      # 
      #     # app/controllers/backend/debtors_controller.rb
      #     def index
      #       @column_store = column_store_for Debtor do |cm|
      #         cm.add :id          
      #         cm.add "full_name_or_company.upcase",   "Full Name",      :sortable => true, :dataIndex => :company
      #         cm.add :email,                          "Email",          :sortable => true
      #         cm.add :piva,                           "Piva",           :sortable => true
      #         cm.add :created_at,                     "Creato il",      :sortable => true, :renderer => :date, :align => :right
      #         cm.add :updated_at,                     "Aggiornato il",  :sortable => true, :renderer => :datetime, :align => :right
      #       end
      #     
      #       respond_to do |format|
      #         format.js 
      #         format.json do
      #           render :json => @column_store.store_data(params)
      #           
      #           # or you can manually do:
      #             # debtors           = Debtor.search(params)
      #             # debtors_count     = debtors.size
      #             # debtors_paginated = debtors.paginate(params)
      #             # render :json => { :results => @column_store.store_data_from(debtors_paginated), :count => debtors_count }
      #         end
      #       end
      #     end
      # 
      #     # app/views/backend/index.rjs
      #     page.grid do |grid|
      #       grid.id "debtors-grid" # If you don't set this columns are not saved in cookies
      #       grid.title "List al debtors"
      #       grid.base_path "/backend/debtors"
      #       grid.forgery_protection_token request_forgery_protection_token
      #       grid.authenticity_token form_authenticity_token
      #       grid.tbar  :default
      #       grid.store do |store|
      #         store.url "/backend/debtors.json"
      #         store.fields @column_store.store_fields
      #       end
      #       grid.columns do |columns|
      #         columns.fields @column_store.column_fields
      #       end
      #       grid.bbar  :store => grid.get_store, :pageSize => params[:limit] # Remember to add after defining store!
      #     end
      # 
      def column_store_for(model, &block)
        ColumnStore.new(model, &block)
      end
      
      class ColumnStore#:nodoc:
        attr_reader :data

        def initialize(model, &block)#:nodoc
          @model = model
          @data = []
          yield self
        end

        # Method for add columns to the Column Model
        def add(method, header=nil, options={})
          options[:method]      = method
          options[:dataIndex] ||= method
          # Setting hidden and removing query for 
          # items that don't have headers
          if header.blank?
            options[:hidden]  = true
            options[:query]   = false
          end
          
          # Reformat query 
          case options[:dataIndex]
            when Symbol
              options[:dataIndex] = "#{@model.table_name}.#{options[:dataIndex]}"
            when Array
              options[:dataIndex] = options[:dataIndex].collect do |f| 
                f.is_a?(Symbol) ? "#{@model.table_name}.#{f}" : f 
              end.join(",")
            else
              options[:dataIndex] = "#{@model.table_name}.#{options[:dataIndex]}"
          end
          
          # Reformat dataIndex
          options[:mapping] ||= options[:dataIndex].to_s.downcase.gsub(/[^a-z0-9]+/, '_').
                                                                  gsub(/-+$/, '_').
                                                                  gsub(/^-+$/, '_')

          # Reformat header
          options[:header] = header || options[:dataIndex].to_s.humanize

          @data << options
        end

        # Return an array config for build an Ext.grid.ColumnModel() config
        def column_fields
          @data.clone.inject([]) do |fields, data|
            # Prevent to removing in the original Hash
            field = data.clone
            field.delete(:method)
            field.delete(:mapping)
            fields << field
            fields
          end
        end
        
        # Return an array config for build an Ext.data.GroupingStore()
        def store_fields
          @data.inject([]) do |fields, data|
            hash = { :name => data[:dataIndex], :mapping => data[:mapping] }
            hash.merge!(:type => data[:renderer]) if data[:renderer] && 
                                                     (data[:renderer] == :date || data[:renderer] == :datetime)
            fields << hash
            fields
          end
        end
        
        # Return data for a custom collection for the ExtJS Ext.data.GroupingStore() json
        def store_data_from(collection)
          collection.inject([]) do |store, c|
            store << @data.inject({ :id => c.id }) do |options, data|
              options[data[:mapping]] = c.instance_eval(data[:method].to_s)
              options
            end
            store
          end
        end
        
        # Return a searched and paginated data collection for the ExtJS Ext.data.GroupingStore() json
        def store_data(params)
          collection           = @model.search(params)
          collection_count     = collection.size
          collection_paginated = collection.paginate(params)
          { :results => store_data_from(collection_paginated), :count => collection_count }
        end

        # Returns an object whose <tt>to_json</tt> evaluates to +code+. Use this to pass a literal JavaScript 
        # expression as an argument to another JavaScriptGenerator method.
        #
        def literal(code)
          ActiveSupport::JSON::Variable.new(code.to_s)
        end
        alias_method :l, :literal
      end
    end
  end
end