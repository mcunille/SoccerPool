# Final Project: Soccer Pool
# Date: 30-Nov-2015
# Authors: A01164759 Mauricio Cunille
#          A01169513 Daniela Ortiz

# As explained in <http://www.railstips.org/blog/archives/2006/11/18/class-and-instance-variables-in-ruby/>
module ClassLevelInheritableAttributes
  def self.included(base)
    base.extend(ClassMethods)    
  end
  
  # Represents class methods
  module ClassMethods
    # Sets the inheritable attributes
    def inheritable_attributes(*args)
      @inheritable_attributes ||= [:inheritable_attributes]
      @inheritable_attributes += args
      args.each do |arg|
        class_eval %(
          class << self; attr_accessor :#{arg} end
        )
      end
      @inheritable_attributes
    end
    
    # Sets the value of those attributes that are inherited.
    def inherited(subclass)
      @inheritable_attributes.each do |inheritable_attribute|
        instance_var = "@#{inheritable_attribute}"
        subclass.instance_variable_set(instance_var, instance_variable_get(instance_var))
      end
    end
  end
end