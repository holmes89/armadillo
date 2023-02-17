package service

import (
	"context"
	"errors"
	"net/http"

	"github.com/holmes89/armadillo/internal"
	v1 "github.com/holmes89/armadillo/internal/handlers/rest/v1"
	"github.com/rs/zerolog/log"
)

var (
	_ v1.LoginApiServicer = (*LoginServicer)(nil)
)

// LoginServicer used to fulfill API servicer
type LoginServicer struct {
	svc internal.LoginService
}

// NewLoginServicer instanciates a new servicer
func NewLoginServicer(svc internal.LoginService) *LoginServicer {
	return &LoginServicer{
		svc: svc,
	}
}

// CreateLogin adds a new Login to the system
func (s *LoginServicer) Authenticate(ctx context.Context, entity v1.Login) (resp v1.ImplResponse, err error) {
	r := internal.Login{
		Username: entity.Username,
		Password: entity.Password,
	}

	if entity.RefreshToken != "" {
		r.RefreshToken = &entity.RefreshToken
	}

	res, err := s.svc.Authenticate(ctx, r)
	if err != nil {
		log.Error().Err(err).Msg("unable to insert Login")
		return resp, errors.New("unable to create Login")
	}

	resp.Code = http.StatusOK
	resp.Body = res
	return resp, nil
}