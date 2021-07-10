describe('LocalDate', function() {
  let dateDisplay,
      timeId = 'weather-date',
      weatherDate = "2021-04-09T16:00:01+00:00"

  describe('#display', function() {
    it('displays formated weather date in local time and langauge', function() {
      setupDOM();
      localDate = new LocalDate(timeId);

      localDate.display();

      expect(dateDisplay.textContent).toEqual('sam. 10 avr.')
    });
  });

  function setupDOM() {
    dateDisplay = document.createElement('time')
    dateDisplay.setAttribute('id', timeId)
    dateDisplay.setAttribute('datetime', weatherDate)

    document.body.appendChild(dateDisplay)
  }
});
