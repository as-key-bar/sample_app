class User
  attr_accessor :name, :email

  def initialize(attributes = {})
    @firstname  = attributes[:firstname]
    @lastname   = attributes[:lastname]
    @email = attributes[:email]
  end

  def fullname
    "#{@firstname} #{@lastname}"
  end

  def formatted_email
    "#{fullname} <#{@email}>"
  end

  def alphabetical_name
    "#{@lastname}, #{@firstname}"
  end 

end
