package login

import (
	"context"
	"errors"
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	cognito "github.com/aws/aws-sdk-go/service/cognitoidentityprovider"
	"github.com/holmes89/armadillo/internal"
	"github.com/rs/zerolog/log"
)

type service struct {
	svc      *cognito.CognitoIdentityProvider
	clientID *string
	poolID   *string
}

func NewService() internal.LoginService {
	clientID := os.Getenv("COGNITO_CLIENT_ID")
	if clientID == "" {
		panic("COGNITO_CLIENT_ID required")
	}
	poolID := os.Getenv("COGNITO_POOL_ID")
	if clientID == "" {
		panic("COGNITO_POOL_ID required")
	}
	session := session.Must(session.NewSession())
	return &service{
		svc:      cognito.New(session),
		clientID: &clientID,
		poolID:   &poolID,
	}
}

func (s *service) Authenticate(ctx context.Context, si internal.Login) (internal.Authentication, error) {
	authInput := &cognito.AdminInitiateAuthInput{
		ClientId:   s.clientID,
		UserPoolId: s.poolID,
	}
	auth := internal.Authentication{}
	if si.RefreshToken != nil {
		log.Info().Msg("authentication using refresh token...")
		authInput.AuthFlow = aws.String(cognito.AuthFlowTypeRefreshToken)
		authInput.AuthParameters = map[string]*string{
			"REFRESH_TOKEN": si.RefreshToken,
		}
	} else {
		log.Info().Msg("authentication using username and password...")
		authInput.AuthFlow = aws.String(cognito.AuthFlowTypeUserPasswordAuth)
		authInput.AuthParameters = map[string]*string{
			"USERNAME": &si.Username,
			"PASSWORD": &si.Password,
		}
	}
	resp, err := s.svc.AdminInitiateAuth(authInput)
	if err != nil {
		log.Error().Err(err).Msg("unable to authenticate user")
		return auth, errors.New("unable to authenticate user")
	}
	if resp.AuthenticationResult.AccessToken != nil {
		auth.Token = *resp.AuthenticationResult.AccessToken
	}
	if resp.AuthenticationResult.RefreshToken != nil {
		auth.RefreshToken = *resp.AuthenticationResult.RefreshToken
	}
	return auth, nil
}
