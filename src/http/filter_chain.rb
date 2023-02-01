# frozen_string_literal: true

# HTTP
module HTTP
  # HTTP request/response filter chain
  # Chain of HTTP request filters
  class FilterChain
    # @param [Array<AbstractFilter>] chain
    def initialize(chain)
      @chain = chain
      @index = -1
    end

    # @return [Array] HTTP request and response
    def filter(request, response)
      unless @chain.empty?
        @index = @index.next
        @chain[@index]&.filter(request, response, self)
      end
      [request, response]
    end
  end
end
