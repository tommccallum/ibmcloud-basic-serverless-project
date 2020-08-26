"use strict";
var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
exports.__esModule = true;
exports.OverrideUrlSerializer = void 0;
// https://github.com/angular/angular/issues/21003
// Try to stop an extra / being appended to the url
// on browser reload.
var router_1 = require("@angular/router");
var OverrideUrlSerializer = /** @class */ (function (_super) {
    __extends(OverrideUrlSerializer, _super);
    function OverrideUrlSerializer() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    OverrideUrlSerializer.prototype.serialize = function (tree) {
        console.log("here " + tree.toString());
        if (tree.toString() === '/') {
            return '';
        }
        return _super.prototype.serialize.call(this, tree);
    };
    return OverrideUrlSerializer;
}(router_1.DefaultUrlSerializer));
exports.OverrideUrlSerializer = OverrideUrlSerializer;
