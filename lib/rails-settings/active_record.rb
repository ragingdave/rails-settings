ActiveRecord::Base.class_eval do
  def self.has_settings
    class_eval do
      def settings
        ScopedSettings.for_target(self)
      end

      def self.settings
        ScopedSettings.for_target(self)
      end

      def settings=(hash)
        hash.each { |k,v| settings[k] = v }
      end

      after_destroy { |user| user.settings.target_scoped.delete_all }

      send :scope, :with_settings, -> do
        joins("JOIN settings ON (settings.target_id = #{self.table_name}.#{self.primary_key} AND settings.target_type = '#{self.base_class.name}')")
          .select("DISTINCT #{self.table_name}.*")
      end

      send :scope, :with_settings_for, ->(var) do
        joins("JOIN settings ON (settings.target_id = #{self.table_name}.#{self.primary_key} AND settings.target_type = '#{self.base_class.name}') AND settings.var = '#{var}'")
      end

      send :scope, :without_settings, -> do
        joins("LEFT JOIN settings ON (settings.target_id = #{self.table_name}.#{self.primary_key} AND settings.target_type = '#{self.base_class.name}')")
          .where("settings.id IS NULL")
      end

      send :scope, :without_settings_for, ->(var) do
        joins("LEFT JOIN settings ON (settings.target_id = #{self.table_name}.#{self.primary_key} AND settings.target_type = '#{self.base_class.name}') AND settings.var = '#{var}'")
          .where("settings.id IS NULL")
      end
    end
  end
end
