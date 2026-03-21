# frozen_string_literal: true

# HTTP
module HTTP
  # HTTP request/response filter chain
  module Filter
    # @param [HTTP::HttpRequest] request
    # @param [HTTP::HttpResponse] response
    # @param [RequestResponseFilterChain] chain
    def filter(request, response, chain)
      raise NotImplementedError
    end
  end
end
