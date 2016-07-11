def rat n
    n.to_s.sub /\/1$/, ''
end

class Func

    def self.concat a, b
        a + b
    end

    def self.add a, b
        rat a.to_r + b.to_r
    end

    def self.subtract a, b
        rat a.to_r - b.to_r
    end

    def self.multiply a, b
        rat a.to_r * b.to_r
    end

    def self.divide a, b
        rat a.to_r / b.to_r
    end

end
