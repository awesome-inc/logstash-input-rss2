# A custom RSS entity
class Entity
  include SAXMachine
  attribute :id
  attribute :name
  element   :text
end
