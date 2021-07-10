class LocalDate {
  constructor(id) {
    this.id = id;
  }

  display() {
    let date = new Date(this._weatherDate.getAttribute('datetime')),
        format = { weekday: 'short', day: 'numeric', month: 'short' };

    this._weatherDate.textContent = date.toLocaleString(undefined, format);
  }

  get _weatherDate() {
    return document.getElementById(this.id);
  }
}
