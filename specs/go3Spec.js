// Generated by CoffeeScript 1.6.3
describe("Test of Go3 browser side code", function() {
  beforeEach(function() {
    return this.zip = new Zipper();
  });
  describe("App Creation Test", function() {
    it("should create a Zipper object", function() {
      expect(this.zip).toBeDefined;
      return expect(this.zip).toEqual(jasmine.any(Zipper));
    });
    return it("should create a LegalPlayablePoints object", function() {
      expect(this.zip.lpp).toBeDefined;
      return expect(this.zip.lpp).toEqual(jasmine.any(LegalPlayablePoints));
    });
  });
  return describe("Board Test", function() {
    return it("should create a Board object", function() {
      expect(this.zip.board).toBeDefined;
      return expect(this.zip.board).toEqual(jasmine.any(Board));
    });
  });
});