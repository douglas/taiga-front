###
# Copyright (C) 2014 Andrey Antukh <niwi@niwi.be>
# Copyright (C) 2014 Jesús Espino Garcia <jespinog@gmail.com>
# Copyright (C) 2014 David Barragán Merino <bameda@dbarragan.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: modules/auth.coffee
###

taiga = @.taiga

class AuthService extends taiga.Service
    @.$inject = ["$rootScope", "$tgStorage", "$tgModel", "$tgHttp"]

    constructor: (@rootscope, @storage, @model, @http) ->
        super()

    getUser: ->
        if @rootscope.user
            return @rootscope.user

        userData = @storage.get("userInfo")
        if userData
            user = @model.make_model("users", userData)
            @rootscope.user = user
            return user

        return null

    setUser: (user) ->
        @rootscope.auth = user
        @rootscope.$broadcast("i18n:change", user.default_language)
        @storage.set("userInfo", user.getAttrs())

    clear: ->
        @rootscope.auth = null
        @storage.remove("userInfo")

    setToken: (token) ->
        @storage.set("token", token)

    getToken: ->
        return @storage.get("token")

    login: (username, password) ->
        url = @urls.resolve("auth")

        data = {
            username: username
            password: password
        }

        return @http.post(url, data).then (data, status) =>
            user = @model.make_model("users", data)
            @.setToken(data["auth_token"])
            @.setUser(user)
            return user

    isAuthenticated: ->
        if @.getUser() != null
            return true
        return false

module = angular.module("taigaAuth", ["taigaResources"])
module.service("$tgAuth", AuthService)