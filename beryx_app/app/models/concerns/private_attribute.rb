module PrivateAttribute
  extend ActiveSupport::Concern

  module ClassMethods
    def prop_readonly(*prop_names)
      prop_names.each do |prop_name|
        private define_method("#{prop_name}=") {|val|
          write_attribute prop_name, val
        }
      end
    end
  end
end