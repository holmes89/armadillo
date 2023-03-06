package internal

import (
	"context"
)

type Login struct {
	Username     string  `json:"username"`
	Password     string  `json:"password"`
	RefreshToken *string `json:"refresh_token"`
	Session      *string `json:"session,omitempty"`
}

type Authentication struct {
	Token        string  `json:"token"`
	RefreshToken string  `json:"refresh_token"`
	Session      *string `json:"session,omitempty"`
}

func (s Login) Type() string {
	return "login"
}

type LoginService interface {
	Authenticate(context.Context, Login) (Authentication, error)
}
