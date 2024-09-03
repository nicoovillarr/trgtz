class Cache {
  constructor() {
    this.cache = {}
  }

  get(key) {
    return !this.cache.hasOwnProperty(key) ? null : this.cache[key].value
  }

  set(key, value, ttl = 10) {
    if (this.cache.hasOwnProperty(key)) {
      clearTimeout(this.cache[key].to)
    }

    this.cache[key] = {
      value,
      to: setTimeout(() => {
        delete this.cache[key]
      }, ttl * 60 * 1000)
    }
  }
}

const cache = new Cache()

module.exports = cache
