# frozen_string_literal: true

module Drivers
  module Scm
    class Base < Drivers::Base
      include Drivers::Dsl::Defaults
      include Drivers::Dsl::Packages
      include Drivers::Dsl::Output

      defaults enable_submodules: true

      def setup
        handle_packages
      end

      def settings
        combined_settings = default_settings
        combined_settings.merge!(app_settings) if configuration_data_source == :app_engine
        combined_settings.merge(custom_settings)
      end

      def default_settings
        base = node['defaults'][driver_type].symbolize_keys.merge(scm_provider: adapter.constantize)
        defaults.merge(base)
      end

      def app_settings
        app_source = app['app_source']
        { scm_provider: adapter.constantize, repository: app_source['url'], revision: app_source['revision'] }
      end

      def custom_settings
        (node['deploy'][app['shortname']][driver_type] || {}).symbolize_keys
      end

      protected

      def app_engine
        app['app_source'].try(:[], 'type')
      end

      def node_engine
        node['deploy'][app['shortname']][driver_type].try(:[], 'adapter')
      end
    end
  end
end
