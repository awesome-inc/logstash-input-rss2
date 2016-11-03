class Entity
  include SAXMachine

  attribute :id
  attribute :name
  element   :text

  def is_nil
    return id.nil? || id.empty? || name.nil? || name.empty?
  end

  def has_text
    return !(text.nil? || !text.empty?)
  end

  def to_s
    return !is_nil ? "[id: #{id}, name: #{name}]" : ""
  end  
end
