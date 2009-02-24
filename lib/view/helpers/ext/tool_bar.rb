module Lipsiadmin
  module Ext
    # Generate a new Ext.Toolbar
    # 
    #   Examples:
    # 
    #     var toolBar = new Ext.Toolbar([{
    #         handler: show();,
    #         text: "Add",
    #         other: "...",
    #         icon: "..."
    #       },{
    #         handler: Backend.app.loadHtml('/accounts/'+accounts_grid.getSelected().id+'/edit'),
    #         text: "Edit",
    #         other: "..."
    #     }]);
    #
    #   grid.tbar do |bar|
    #     bar.add "Add",  :handler => bar.l("show();"), :icon => "...", :other => "..."
    #     bar.add "Edit", :handler => bar.l("Backend.app.loadHtml('/accounts/'+accounts_grid.getSelected().id+'/edit')"), :other => "..."
    #   end
    #
    class ToolBar < Component
      attr_accessor :items
      def initialize(options={}, &block)#:nodoc:
        super({ :items => [] }.merge(options), &block)
      end
      
      # Add new items to a Ext.Toolbar
      # 
      #   # Generates: { handler: show();, text: "Add", other: "...", icon: "..." }
      #   add "Add",  :handler => bar.l("show();"), :icon => "...", :other => "..."
      # 
      def add(name, options={})
        options[:text] = name
        config[:items] << Component.new(options).config
      end
      
      # Return the javascript for create a new Ext.Toolbar
      def to_s
        "var #{get_var} = new Ext.Toolbar([#{config[:items].join(",")}]);"
      end
    end
  end
end