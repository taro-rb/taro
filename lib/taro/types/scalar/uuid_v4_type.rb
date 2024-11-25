class Taro::Types::Scalar::UUIDv4Type < Taro::Types::Scalar::StringType
  self.desc = "A UUID v4 string"
  self.openapi_name = 'UUIDv4'
  self.pattern = /\A\h{8}-?(?:\h{4}-?){3}\h{12}\z/
end
